module TopLevel0 (
  input clk, reset, start,
  output logic done
);
  logic nil;
  logic max_neg;
  logic [7:0] ctr;
  logic [4:0] exp;
  logic [14:0] int1;
  logic sgn;
  logic trap;
  bit [1:0] pgm;
  bit [7:0] DataAddress;
  bit ReadMem = 1'b1;
  bit WriteMem;
  bit [7:0] DataIn;
  wire [7:0] DataOut;

  data_mem #(.AW(8)) data_mem0 (  // Change instance name to data_mem0
    .clk,
    .ReadMem,
    .WriteMem,
    .DataAddress,
    .DataIn,
    .DataOut
  );

  always @(posedge clk) begin
    if (reset) begin
      pgm <= 2'b0;
      ctr <= 8'b0;
      WriteMem <= 1'b0;
      done <= 1'b0;
    end else if (start) begin
      {sgn, int1} = {data_mem0.mem_core[1], data_mem0.mem_core[0]};
      trap = !int1 || int1 == 15'h7FFF;
      exp = 5'd21;
      done <= 1'b0;
      WriteMem <= 1'b0;
      ctr <= 8'b0;
    end else if (!done) begin
      ctr <= ctr + 1;
      if (trap) begin
        exp = 5'b0;
        DataAddress = 8'd2;
        DataIn = 8'b0;
        WriteMem = 1'b1;
        #10ns;
        DataAddress = 8'd3;
        DataIn = {sgn, 5'b0};
        WriteMem = 1'b1;
        #10ns;
        WriteMem = 1'b0;
        done = 1'b1;
      end else begin
        if (int1[14] == 1'b0 && ctr < 15) begin
          int1 = int1 << 1;
          exp = exp - 1;
        end else if (int1[14] == 1'b1 || ctr >= 15) begin
          DataAddress = 8'd2;
          DataIn = int1[13:6];
          WriteMem = 1'b1;
          #10ns;
          DataAddress = 8'd3;
          DataIn = {sgn, exp[4:0], int1[5:4]};
          WriteMem = 1'b1;
          #10ns;
          WriteMem = 1'b0;
          done = 1'b1;
        end
      end
    end
  end
endmodule