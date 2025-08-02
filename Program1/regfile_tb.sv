module regfile_tb;
  logic clk, reg_write, reset;
  logic [2:0] rd, rs;
  logic [7:0] data_in, out_rd, out_rs;
  RegFile regfile (.clk, .reg_write, .reset, .rd, .rs, .data_in, .out_rd, .out_rs);

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    $display("Testing RegFile module");
    reset = 1; #10; reset = 0; #10;
    // Write to R1
    rd = 3'd1; data_in = 8'h55; reg_write = 1; #10;
    reg_write = 0; #10;
    rs = 3'd1; #10;
    assert (out_rs == 8'h55) else $error("RegFile R1 read failed: %h", out_rs);
    $display("R1 write/read: %h", out_rs);

    // Test reset
    reset = 1; #10; reset = 0; #10;
    rs = 3'd1; #10;
    assert (out_rs == 8'h00) else $error("RegFile reset failed: %h", out_rs);
    $display("R1 after reset: %h", out_rs);

    $display("RegFile test completed");
    $finish;
  end
endmodule