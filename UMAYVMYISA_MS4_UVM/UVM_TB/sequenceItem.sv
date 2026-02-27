import system_widths_pkg::*;
class trace extends uvm_sequence_item;
    rand logic [31:0] instruction;
    rand logic [corewidth-1:0] targetCore;
    //rand logic [ADDR_W-1:0] addr;
    //rand logic [DATA_W-1:0] wdata;
    //rand int unsigned core_id;
    //rand bit we;
    //bit mem_req;

    //logic [DATA_W-1:0] rdata;
    //bit mem_done;

    constraint validCore {targetCore inside {[0:CORES]};}
    constraint validInstruction {instruction[3:0] inside{[0:13]};
                                 instruction[8:4] inside{[0:31]};
                                 instruction[13:9] inside {[0:31]};
                                 instruction [31:14] inside {[0:128]};//what are these bits for?

    }

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
endclass
