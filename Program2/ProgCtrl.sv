module ProgCtrl (
  input clk, reset, branch, branch_conditional, zero,
  input [6:0] target,
  output logic [6:0] PC
);
  always_ff @(posedge clk) begin
    if (!reset) $display("Cycle: Branch = %b, Branch_conditional = %b, Zero = %b, Target = %h, Current PC = %h, Next PC = %h", branch, branch_conditional, zero, target, PC, (branch && (!branch_conditional || zero)) ? target : PC + 1);
    if (reset) PC <= 7'b0;
    else if (branch && (!branch_conditional || zero)) PC <= target;
    else PC <= PC + 1;
  end
endmodule