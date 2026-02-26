import system_widths_pkg::*;
class trace extends uvm_sequence_item;
    rand logic [ADDR_W-1:0] addr;
    rand logic [DATA_W-1:0] wdata;
    rand int unsigned core_id;
    rand bit we;
    bit mem_req;

    logic [DATA_W-1:0] rdata;
    bit mem_done;

    constraint c_core {core_id inside {[0:31]};}
    constraint c_addr {addr inside {[0:(1<<ADDR_W)-1]};}

    `uvm_object_utils_begin(trace)
        `uvm_field_int(mem_addr, UVM_DEFAULT)
        `uvm_field_int(mem_write, UVM_DEFAULT)
        `uvm_field_int(mem_read, UVM_DEFAULT)
        `uvm_field_int(mem_we, UVM_DEFAULT)
        `uvm_field_int(mem_req, UVM_DEFAULT)
        `uvm_field_int(mem_done, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "trace");
        super.new(name);
    endfunction
endclass
