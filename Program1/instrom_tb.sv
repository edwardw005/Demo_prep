module instrom_tb;
  logic [6:0] InstAddress;
  logic [8:0] InstOut;
  InstROM instrom (.InstAddress, .InstOut);

  initial begin
    $display("Testing InstROM module");
    // Test key instructions
    InstAddress = 7'd0; #10;
    assert (InstOut == 9'b100000000) else $error("InstROM[0] incorrect: %h", InstOut);
    $display("InstROM[0] = %h", InstOut);

    InstAddress = 7'd4; #10;
    assert (InstOut == 9'b010011000) else $error("InstROM[4] incorrect: %h", InstOut);
    $display("InstROM[4] = %h", InstOut);

    InstAddress = 7'd15; #10;
    assert (InstOut == 9'b100000000) else $error("InstROM[15] incorrect: %h", InstOut);
    $display("InstROM[15] = %h", InstOut);

    $display("InstROM test completed");
    $finish;
  end
endmodule