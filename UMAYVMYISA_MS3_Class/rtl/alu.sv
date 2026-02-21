// alu.sv 
// behavioral implementation
// will eventually transistion to booth implementation
import opcode_pkg::*;

module alu (
  input  logic [3:0]  alu_op,
  input  logic [31:0] alu_a,
  input  logic [31:0] alu_b,
  output logic [31:0] alu_result,
  output logic        alu_done
);

  logic signed [31:0] a, b;

  always_comb begin
    a = alu_a;
    b = alu_b;

    unique case (opcode_t'(alu_op))
      NOP: alu_result = 32'h0;
      ADD: alu_result = a + b;
      SUB: alu_result = a - b;
      AND: alu_result = alu_a & alu_b;
      LSL: alu_result = alu_a << 1;
      LSR: alu_result = alu_a >> 1;       

      MUL: alu_result = a * b;                 

      // Special Functions
      SP1: alu_result = (a * b) - a;                 
      SP2: alu_result = (a * 4 * b) - a;      
      SP3: alu_result = (a * b) + a;                 
      SP4: alu_result = (a * 3);                        
      SP5: alu_result = (a * b) + b;                

      // Reserved
      RES1, RES2: alu_result = 32'h0;

      default: alu_result = 32'h0;
    endcase

    alu_done = 1'b1; 
  end

endmodule