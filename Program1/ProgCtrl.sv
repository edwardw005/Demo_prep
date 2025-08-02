module ProgCtrl (
  input clk, reset, branch, branch_conditional, zero,
  input [6:0] target,
  output logic [6:0] PC
);
  always_ff @(posedge clk) begin
    if (reset) begin
      PC <= 7'h00; // Initialize PC on reset
    end else if (branch && (!branch_conditional || zero)) begin
      PC <= target; // Take branch if unconditional or conditional and zero
    end else begin
      PC <= PC + 7'h01; // Increment PC
    end
  end
endmodule