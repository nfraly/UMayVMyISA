import system_widths_pkg::*;
class trace extends uvm_sequence_item;
    rand logic [27:0] payload;
    rand logic [3:0] opCode;
    rand logic [corewidth-1:0] targetCore;
    logic [31:0] instruction;
    //rand logic [ADDR_W-1:0] addr;
    //rand logic [DATA_W-1:0] wdata;
    //rand int unsigned core_id;
    //rand bit we;
    //bit mem_req;

    //logic [DATA_W-1:0] rdata;
    //bit mem_done;

    constraint validCore {targetCore inside {[0:CORES]};}
    constraint validInstruction {opCode[3:0] inside{[0:13]};}
    //constraint validPayload {
    //    unique case (opCode)
    //        4'b0000:
    //        4'b0001:
    //        4'b0010:
    //        4'b0011:
    //        4'b0100:
    //        4'b0101:
    //        4'b0110:
    //        4'b0111:
    //        4'b1000:
    //        4'b1001:
    //        4'b1010:
    //        4'b1011:
    //        4'b1100:
    //        4'b1101:
    //        4'b1110:
    //        4'b1111:

    `uvm_object_utils_begin(trace)
        `uvm_field_int(instruction, UVM_DEFAULT)
        `uvm_field_int(targetCore, UVM_DEFAULT)
        //`uvm_field_int(mem_read, UVM_DEFAULT)
        //`uvm_field_int(mem_we, UVM_DEFAULT)
        //`uvm_field_int(mem_req, UVM_DEFAULT)
        //`uvm_field_int(mem_done, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "trace");
        super.new(name);
    endfunction

    function isMem
endclass
