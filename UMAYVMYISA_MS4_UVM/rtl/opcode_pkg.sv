// opcode_pkg.sv
// Since ALU,IU and MIU will utilize opcodes, define them once
package opcode_pkg;
  typedef enum logic [3:0] {
    NOP = 4'b0000,
    ADD = 4'b0001,
    AND = 4'b0010,
    SUB = 4'b0011,
    MUL = 4'b0100,
    LDR = 4'b0101,
    STR = 4'b0110,
    LSR = 4'b0111,
    LSL = 4'b1000,
    // Special functions
    SP1 = 4'b1001,
    SP2 = 4'b1010,
    SP3 = 4'b1011,
    SP4 = 4'b1100,
    SP5 = 4'b1101,
    // Reserved Functions
    RES1 = 4'b1110,
    RES2 = 4'b1111
  } opcode_t;
endpackage