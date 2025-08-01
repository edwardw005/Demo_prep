module RegFile (
  input clk, reg_write, reset,
  input [2:0] rd, rs,
  input [7:0] data_in,
  output logic [7:0] out_rd, out_rs
);
  logic [7:0] regs [0:7];
  always_ff @(posedge clk) begin
    if (reset) begin
      for (int i = 0; i < 8; i++) regs[i] <= 8'b0;
    end else if (reg_write) begin
      regs[rd] <= data_in;
    end
  end
  always_comb begin
    out_rd = regs[rd];
    out_rs = regs[rs];
  end
endmodule