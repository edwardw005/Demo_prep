module InstROM (
  input  logic [6:0] InstAddress,
  output logic [8:0] InstOut
);
  logic [8:0] rom [0:127];

  initial begin
    $readmemb("instrom_init.txt", rom);
  end

  always_comb begin
    InstOut = rom[InstAddress];
  end
endmodule