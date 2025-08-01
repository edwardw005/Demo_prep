module DataMem (
  input clk, mem_write,
  input [5:0] addr,  // 6-bit address
  input [7:0] data_in,
  output logic [7:0] data_out
);
  logic [7:0] mem [0:63];
  always_ff @(posedge clk) begin
    if (mem_write) mem[addr] <= data_in;
  end
  always_comb data_out = mem[addr];
endmodule
