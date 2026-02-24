class reg_item extends uvm_sequence_item;
    rand bit [ADDR_W-1:0] mem_addr;
    rand bit [DATA_W-1:0] mem_write;
    rand bit mem_we;
    bit mem_req;

    bit [DATA_W-1:0] mem_read;
    bit mem_done;

    `uvm_object_utils_begin(reg_item)
        `uvm_field_int(mem_addr, UVM_DEFAULT)
        `uvm_field_int(mem_write, UVM_DEFAULT)
        `uvm_field_int(mem_read, UVM_DEFAULT)
        `uvm_field_int(mem_we, UVM_DEFAULT)
        `uvm_field_int(mem_req, UVM_DEFAULT)
        `uvm_field_int(mem_done, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "reg_item");
        super.new(name);
    endfunction
endclass
