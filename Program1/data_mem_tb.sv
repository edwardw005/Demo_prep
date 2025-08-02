module data_mem_tb;
  logic clk, ReadMem, WriteMem;
  logic [7:0] DataAddress, DataIn, DataOut;
  data_mem #(.AW(8)) dm (.clk, .DataAddress, .ReadMem, .WriteMem, .DataIn, .DataOut);

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    $display("Testing data_mem module");
    // Write to memory
    DataAddress = 8'h00; DataIn = 8'hAA; WriteMem = 1; ReadMem = 0; #10;
    WriteMem = 0; #10;
    $display("Write: M[0] = %h", DataIn);

    // Read from memory
    ReadMem = 1; #10;
    assert (DataOut == 8'hAA) else $error("Read failed: DataOut=%h", DataOut);
    $display("Read: M[0] = %h", DataOut);

    // Test high-impedance
    ReadMem = 0; #10;
    assert (DataOut === 8'bZ) else $error("High-Z failed: DataOut=%h", DataOut);
    $display("High-Z: DataOut=%h", DataOut);

    $display("data_mem test completed");
    $finish;
  end
endmodule