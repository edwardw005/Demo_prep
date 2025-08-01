module TopLevel (
  input clk, reset,
  output logic done
);
  logic [6:0] PC, branch_target;
  logic [8:0] instruction;
  logic [2:0] alu_op, rd, rs;
  logic reg_write, mem_read, mem_write, branch, branch_conditional, zero;
  logic [7:0] alu_out, reg_out_rd, reg_out_rs, mem_out, reg_data_in;

  ProgCtrl prog_ctrl (.clk, .reset, .branch, .branch_conditional, .zero, .target(branch_target), .PC);

  InstROM inst_rom (.InstAddress(PC), .InstOut(instruction));

  assign rd = instruction[5:3];
  assign rs = instruction[2:0];

  CTRL ctrl (.instruction, .alu_op, .reg_write, .mem_read, .mem_write, .branch, .branch_conditional);

  RegFile reg_file (.clk, .reg_write, .rd, .rs, .data_in(reg_data_in), .out_rd(reg_out_rd), .out_rs(reg_out_rs));

  ALU alu (.in1(reg_out_rd), .in2(reg_out_rs), .op(alu_op), .out(alu_out), .zero);

  DataMem data_mem (.clk, .mem_write, .addr(reg_out_rs[5:0]), .data_in(reg_out_rd), .data_out(mem_out));

  LUT lut (.index(instruction[5:0]), .out(branch_target));

  // Mux for reg_data_in: ALU or memory
  assign reg_data_in = mem_read ? mem_out : alu_out;

  // Done signal (example: set when PC reaches end; adjust based on program)
  assign done = (PC == 7'd127);  // Or based on a specific instruction/halt

endmodule
