module TopLevel (
  input clk, reset, start,
  output logic done
);
  logic [6:0] PC, branch_target;
  logic [8:0] instruction;
  logic [2:0] alu_op, rd, rs, effective_rd, effective_rs;
  logic reg_write, mem_read, mem_write, branch, branch_conditional, zero;
  logic [7:0] alu_out, reg_out_rd, reg_out_rs, mem_out, reg_data_in;
  logic start_q;
  logic [9:0] cycle_ctr;
  logic [6:0] prev_PC;

  ProgCtrl prog_ctrl (
    .clk, 
    .reset(reset || (start_q && !start)),
    .branch, 
    .branch_conditional, 
    .zero, 
    .target(branch_target), 
    .PC
  );

  InstROM inst_rom (
    .InstAddress(PC), 
    .InstOut(instruction)
  );

  always_comb begin
    if (instruction[8:6] == 3'b100 || instruction[8:6] == 3'b101) begin
      effective_rd = 3'b0;
      effective_rs = 3'b0;
    end else begin
      effective_rd = instruction[5:3];
      effective_rs = instruction[2:0];
    end
  end

  CTRL ctrl (
    .instruction, 
    .alu_op, 
    .reg_write, 
    .mem_read, 
    .mem_write, 
    .branch, 
    .branch_conditional
  );

  RegFile reg_file (
    .clk, 
    .reg_write, 
    .reset, 
    .rd(effective_rd), 
    .rs(effective_rs), 
    .data_in(reg_data_in), 
    .out_rd(reg_out_rd), 
    .out_rs(reg_out_rs)
  );

  ALU alu (
    .in1(reg_out_rd), 
    .in2(reg_out_rs), 
    .op(alu_op), 
    .out(alu_out), 
    .zero
  );

  data_mem #(.AW(8)) data_mem1 (
    .clk, 
    .ReadMem(mem_read), 
    .WriteMem(mem_write), 
    .DataAddress(instruction[7:0]),  // Use literal address
    .DataIn(reg_out_rd), 
    .DataOut(mem_out)
  );

  LUT lut (
    .index(instruction[5:0]), 
    .out(branch_target)
  );

  assign reg_data_in = mem_read ? mem_out : alu_out;

  always_ff @(posedge clk) begin
    if (reset) begin
      start_q <= 1'b0;
      cycle_ctr <= 10'b0;
      done <= 1'b0;
      prev_PC <= 7'b0;
    end else begin
      start_q <= start;
      cycle_ctr <= cycle_ctr + 1;
      prev_PC <= PC;
      if ((instruction[8:6] == 3'b111 && instruction[5:0] == 6'b0 && !done) ||
          (PC == prev_PC && !done) ||
          (PC == 7'd25 && instruction == 9'b111000010 && !done)) begin  // Trap halt
        done <= 1'b1;
      end else begin
        done <= 1'b0;
      end
      if (cycle_ctr == 10'd1000) begin
        $display("Timeout: Infinite loop detected at PC = %h, instruction = %b", PC, instruction);
        $finish;
      end
    end
  end

  always @(posedge clk) begin
    if (!reset) begin
      $display("Cycle %0d: PC = %h, Instruction = %b, R0 = %h, R1 = %h, R2 = %h, R3 = %h, R4 = %h, R5 = %h, R6 = %h, R7 = %h, Zero = %b, Mem[8] = %h, Mem[9] = %h, Mem[10] = %h, Mem[11] = %h",
               cycle_ctr, PC, instruction, reg_file.regs[0], reg_file.regs[1], reg_file.regs[2], reg_file.regs[3], reg_file.regs[4], reg_file.regs[5], reg_file.regs[6], reg_file.regs[7], zero,
               data_mem1.mem_core[8], data_mem1.mem_core[9], data_mem1.mem_core[10], data_mem1.mem_core[11]);
    end
  end
endmodule