import system_widths_pkg::*;
class trace #(parameter CORES = 3) extends uvm_sequence_item;
    localparam corewidth = $clog2(CORES);
    rand logic [corewidth-1:0] targetCore;
    rand logic [3:0] opCode;
    rand logic [4:0] rs, rd, rt;
    rand logic [1:0] offset;
    rand logic [2:0] index;
    rand logic [5:0] tag;
    logic [10:0] addr;
    rand logic rst;
    logic [31:0] instruction;
    logic [7:0] address;
    logic [4:0] register;
    logic [31:0] aluA;
    logic [31:0] aluB;
    logic [31:0] memData;
    logic [31:0] result;

    constraint validCore {targetCore inside {[0:CORES-1]};}
    constraint validInstruction {opCode[3:0] inside{[0:13]};}

    function void post_randomize();
        if (opCode == 4'b0110 || opCode == 4'b0101) begin //If it's a load or store
            instruction = {>>{opCode, rs, tag, index, offset}};
            {rd, rt} = 'x;
        end
        else begin //literally every other opcode
            instruction = {>>{opCode, rd, rs, rt}};
            {offset, index, tag} = 'x;
        end
        addr = {tag, index, offset};
    endfunction

    `uvm_object_utils_begin(trace#(3))
        `uvm_field_int(targetCore, UVM_DEFAULT)
        `uvm_field_int(instruction, UVM_DEFAULT)
        `uvm_field_int(rd, UVM_DEFAULT)
        `uvm_field_int(rt, UVM_DEFAULT)
        `uvm_field_int(rs, UVM_DEFAULT)
        `uvm_field_int(addr, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "trace");
        super.new(name);
    endfunction

endclass
