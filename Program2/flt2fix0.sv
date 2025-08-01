// behavioral model of float to fix 8.8 converter rev. 2025.05.24
// not intended to be synthesizable -- just shows the algorithm
// CSE141L
module TopLevel0 (
  input clk, reset, start,
  output logic done
);
  logic [15:0] flt_in;
  logic [14:0] int_out;
  logic [4:0] exp;
  logic [41:0] int_frac;
  logic sign, start_q;
  logic [7:0] ctr;
  logic [7:0] dm_out, dm_in, dm_addr;

  data_mem data_mem1(.clk(clk), .WriteMem('0), .DataOut(dm_out), .DataIn(dm_in), .DataAddress(dm_addr), .ReadMem('1));

  always @(posedge clk) begin
    if (reset) begin
      start_q <= '0;
      ctr <= '0;
    end else begin
      start_q <= start;
      ctr <= ctr + 'b1;
    end
  end

  always begin
    wait(start_q && !start);
    flt_in = {data_mem1.mem_core[5], data_mem1.mem_core[4]};
    sign = flt_in[15];
    exp = flt_in[14:10];
    int_frac = {31'b0, |flt_in[14:10], flt_in[9:0]};
    int_frac = int_frac << exp;
    int_out = int_frac[31:17];
    if (exp > 5'b10110) begin
      if (sign) {data_mem1.mem_core[7], data_mem1.mem_core[6]} = 16'hffff;
      else {data_mem1.mem_core[7], data_mem1.mem_core[6]} = 16'h7fff;
    end else begin
      if (int_frac[41:32]) int_out = 15'h7fff;
      {data_mem1.mem_core[7], data_mem1.mem_core[6]} = {sign, int_out};
    end
    #20ns done = '1;
    #20ns done = '0;
  end
endmodule