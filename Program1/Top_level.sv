module TopLevel (
  input  logic clk,
  input  logic reset,
  input  logic start,
  output logic done
);
  logic [6:0] PC;
  logic [8:0] instruction;
  logic [2:0] opcode, rd, rs;
  logic [5:0] imm6;
  logic reg_write, mem_read, mem_write, branch_zero, branch_always, halt;
  logic [7:0] reg_out_rd, reg_out_rs, alu_out, mem_out, reg_data_in;
  logic zero;
  logic imm_mode;

  // Instruction Fetch
  InstROM inst_rom(
    .InstAddress(PC),
    .InstOut(instruction)
  );

  // Decode fields
  assign opcode = instruction[8:6];
  assign rd     = instruction[5:3];
  assign rs     = instruction[2:0];
  assign imm6   = instruction[5:0];
  assign imm_mode = (opcode == 3'b011); // LDI only

  // Control Unit
  CTRL ctrl(
    .instruction(instruction),
    .reg_write(reg_write),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .branch_zero(branch_zero),
    .branch_always(branch_always),
    .halt(halt)
  );

  // Register File
  RegFile reg_file(
    .clk(clk),
    .reset(reset),
    .reg_write(reg_write),
    .rd(rd),
    .rs(rs),
    .data_in(reg_data_in),
    .out_rd(reg_out_rd),
    .out_rs(reg_out_rs)
  );

  // ALU
  ALU alu(
    .in1(reg_out_rd),
    .in2(reg_out_rs),
    .op(opcode),
    .imm6(imm6),
    .imm_mode(imm_mode),
    .out(alu_out),
    .zero(zero)
  );

  // Data Memory
  data_mem data_mem1(
    .clk(clk),
    .ReadMem(mem_read),
    .WriteMem(mem_write),
    .DataAddress(reg_out_rs),
    .DataIn(reg_out_rd),
    .DataOut(mem_out)
  );

  // Program Counter Control
  ProgCtrl prog_ctrl (
    .clk(clk),
    .reset(reset),
    .branch_zero(branch_zero),
    .branch_always(branch_always),
    .zero(zero),
    .halt(halt),
    .target(imm6),
    .PC(PC)
  );

  // Writeback logic
  assign reg_data_in = mem_read ? mem_out : alu_out;

  // Set done flag when HALT fetched
  always_ff @(posedge clk) begin
    if (reset)
      done <= 0;
    else if (halt)
      done <= 1;
  end

endmodule