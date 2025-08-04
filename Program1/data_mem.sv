module data_mem (
  input  logic clk,
  input  logic ReadMem,
  input  logic WriteMem,
  input  logic [7:0] DataAddress,
  input  logic [7:0] DataIn,
  output logic [7:0] DataOut
);
  logic [7:0] mem_core [0:255];

  always_ff @(posedge clk) begin
    if (WriteMem)
      mem_core[DataAddress] <= DataIn;
//      $display("WRITE mem[%0d] = %h", DataAddress, DataIn);
  end

  always_comb begin
    if (ReadMem)
      DataOut = mem_core[DataAddress];
//      $display("Read mem[%0d] = %h", DataAddress, mem_core[DataAddress]);
    else
      DataOut = 8'b0;
  end
endmodule