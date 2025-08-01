// revised 2025.07.23 for sign-and-magnitude fixed point
// test bench for float to fix 8.8 revised 2025.05.24
// CSE141L version w/o rounding required
module flt2fix_tb_noround();
  bit clk = '0, reset = '1, req;
  wire ack0, ack;
  bit [15:0] flt_in = '0;
  logic sign;
  logic signed [5:0] exp;
  logic [10:0] mant;
  real int_equiv, mant2, int_out, scaled;
  logic [14:0] math;
  int score0, score1, count;

  TopLevel0 f2(.clk(clk), .reset(reset), .start(req), .done(ack0));
  TopLevel f3(.clk(clk), .reset(reset), .start(req), .done(ack));

  always begin
    #5ns clk = 1;
    #5ns clk = 0;
  end

  initial begin
    flt_in = '0; disp;
    flt_in = 16'b0_01111_0000000000; disp;
    flt_in = 16'b0_01111_1000000000; disp;
    flt_in = 16'b0_01111_0100000000; disp;
    flt_in = 16'b0_01111_1100000000; disp;
    flt_in = 16'b0_10000_0000000000; disp;
    flt_in = 16'b0_10000_1000000000; disp;
    flt_in = 16'b0_10000_1100000000; disp;
    flt_in = 16'b0_10000_1110000000; disp;
    flt_in = 16'b0_10000_0001000000; disp;
    flt_in = 16'b0_10000_0101000000; disp;
    flt_in = 16'b0_10000_0111000000; disp;
    flt_in = 16'b0_10010_1100000000; disp;
    flt_in = 16'b0_10010_1110000000; disp;
    flt_in = 16'b0_11000_1100000000; disp;
    flt_in = 16'b0_11001_1100000000; disp;
    flt_in = 16'b0_11101_1110000000; disp;
    flt_in = 16'b0_11110_1110000000; disp;
    flt_in = 16'h8000; disp;
    flt_in = 16'b1_01111_0000000000; disp;
    flt_in = 16'b1_01111_0100000000; disp;
    flt_in = 16'b1_10000_0000000000; disp;
    flt_in = 16'b1_10000_1000000000; disp;
    flt_in = 16'b1_10000_0001000000; disp;
    flt_in = 16'b1_10000_0001000000; disp;
    flt_in = 16'b1_10010_1100000000; disp;
    flt_in = 16'b1_10010_1110000000; disp;
    flt_in = 16'b1_11000_1100000000; disp;
    flt_in = 16'b1_11001_1100000000; disp;
    flt_in = 16'b1_11101_1110000000; disp;
    flt_in = 16'b1_11110_1110000000; disp;
    #20ns $display("correct %d out of total %d", score0, count);
    $display("correct %d out of total %d", score1, count);
    $stop;
  end

  task disp();
    reset = 1;
    #10ns;
    reset = 0;
    {f2.data_mem1.mem_core[5], f2.data_mem1.mem_core[4]} = flt_in;
    {f3.data_mem1.mem_core[5], f3.data_mem1.mem_core[4]} = flt_in;
    #10ns req = '1;
    #10ns req = '0;
    sign = flt_in[15];
    exp = flt_in[14:10] - 15;
    mant[10] = |flt_in[14:10];
    mant[9:0] = flt_in[9:0];
    mant2 = mant / 1024.0;
    wait(ack);
    if (exp >= 7) begin
      math = 15'h7fff;
    end else begin
      int_out = mant2 * 2 ** exp;
      scaled = int_out * 256.0;
      math = int'(scaled);
    end
    #20ns $display("%f * 2**%d = %f = %d", mant2, exp, int_equiv, int_out);
    $display("original binary = %b_%b_%b", flt_in[15], flt_in[14:10], flt_in[9:0]);
    $display("from MAT = %b = %h", {sign, math[14:0]}, {sign, math[14:0]});
    #20ns $display("from dum = %b = %h", {f2.data_mem1.mem_core[7], f2.data_mem1.mem_core[6]}, {f2.data_mem1.mem_core[7], f2.data_mem1.mem_core[6]});
    $display("from DUT = %b = %h", {f3.data_mem1.mem_core[7], f3.data_mem1.mem_core[6]}, {f3.data_mem1.mem_core[7], f3.data_mem1.mem_core[6]});
    count++;
    if ({f3.data_mem1.mem_core[7], f3.data_mem1.mem_core[6]} == {f2.data_mem1.mem_core[7], f2.data_mem1.mem_core[6]}) score0++;
    if ({sign, math} == {f3.data_mem1.mem_core[7], f3.data_mem1.mem_core[6]}) score1++;
    $display(" ct = %d, score0 = %d, score1 = %d", count, score0, score1);
  endtask
endmodule