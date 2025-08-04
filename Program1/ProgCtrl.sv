module ProgCtrl (
  input  logic clk,
  input  logic reset,
  input  logic branch_zero,
  input  logic branch_always,
  input  logic zero,
  input  logic halt,
  input  logic [5:0] target,
  output logic [6:0] PC
);
  always_ff @(posedge clk) begin
    if (reset)
      PC <= 0;
    else if (halt)
      PC <= PC; // Freeze on HALT
    else if ((branch_zero && zero) || branch_always)
      PC <= {1'b0, target}; // Zero-extend target
    else
      PC <= PC + 1;
  end
endmodule