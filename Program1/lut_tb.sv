module lut_tb;
  logic [5:0] index;
  logic [6:0] out;
  LUT lut (.index, .out);

  initial begin
    $display("Testing LUT module");
    // Test key LUT entries
    index = 6'd0; #10;
    assert (out == 7'd15) else $error("LUT[0] incorrect: %h", out);
    $display("LUT[0] = %h", out);

    index = 6'd2; #10;
    assert (out == 7'd18) else $error("LUT[2] incorrect: %h", out);
    $display("LUT[2] = %h", out);

    index = 6'd5; #10;
    assert (out == 7'd19) else $error("LUT[5] incorrect: %h", out);
    $display("LUT[5] = %h", out);

    $display("LUT test completed");
    $finish;
  end
endmodule