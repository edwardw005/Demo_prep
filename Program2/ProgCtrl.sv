module ProgCtrl (
  input clk, reset, branch, branch_conditional, zero,
  input [6:0] target,
  output logic [6:0] PC
);
  always_ff @(posedge clk) begin
    if (reset) PC <= 7'b0;
    else if (branch && (!branch_conditional || zero)) PC <= target;
    else PC <= PC + 1;
  end
endmodule