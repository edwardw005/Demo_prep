module alu_tb;
  logic [7:0] in1, in2, out;
  logic [2:0] op;
  logic zero;
  ALU alu (.in1, .in2, .op, .out, .zero);

  initial begin
    $display("Testing ALU module");
    // Test ADD
    in1 = 8'h05; in2 = 8'h03; op = 3'b000; #10;
    assert (out == 8'h08 && zero == 0) else $error("ADD failed: out=%h, zero=%b", out, zero);
    $display("ADD: %h + %h = %h, zero=%b", in1, in2, out, zero);

    // Test SUB
    in1 = 8'h05; in2 = 8'h03; op = 3'b001; #10;
    assert (out == 8'h02 && zero == 0) else $error("SUB failed: out=%h, zero=%b", out, zero);
    $display("SUB: %h - %h = %h, zero=%b", in1, in2, out, zero);

    // Test AND
    in1 = 8'h0F; in2 = 8'hF0; op = 3'b010; #10;
    assert (out == 8'h00 && zero == 1) else $error("AND failed: out=%h, zero=%b", out, zero);
    $display("AND: %h & %h = %h, zero=%b", in1, in2, out, zero);

    // Test XOR
    in1 = 8'h0F; in2 = 8'hF0; op = 3'b011; #10;
    assert (out == 8'hFF && zero == 0) else $error("XOR failed: out=%h, zero=%b", out, zero);
    $display("XOR: %h ^ %h = %h, zero=%b", in1, in2, out, zero);

    // Test default case
    in1 = 8'hFF; in2 = 8'hFF; op = 3'b100; #10;
    assert (out == 8'h00 && zero == 1) else $error("Default failed: out=%h, zero=%b", out, zero);
    $display("Default: out=%h, zero=%b", out, zero);

    $display("ALU test completed");
    $finish;
  end
endmodule