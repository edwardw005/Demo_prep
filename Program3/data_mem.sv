module data_mem #(parameter AW=8)(
  input clk,
  input [AW-1:0] DataAddress,
  input ReadMem,
  input WriteMem,
  input [7:0] DataIn,
  output logic [7:0] DataOut
);
  logic [7:0] mem_core [2**AW];
  always_comb if(ReadMem) DataOut = mem_core[DataAddress];
  else DataOut = 16'bZ;
  always_ff @(posedge clk) if (WriteMem) mem_core[DataAddress] <= DataIn;
endmodule