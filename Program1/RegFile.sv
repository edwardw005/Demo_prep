module RegFile (
  input clk, reg_write,
  input [2:0] rd, rs,  // Register addresses
  input [7:0] data_in,
  output logic [7:0] out_rd, out_rs
);
  logic [7:0] regs [0:7];
  always_ff @(posedge clk) begin
    if (reg_write) regs[rd] <= data_in;
  end
  always_comb begin
    out_rd = regs[rd];
    out_rs = regs[rs];
  end
endmodule
