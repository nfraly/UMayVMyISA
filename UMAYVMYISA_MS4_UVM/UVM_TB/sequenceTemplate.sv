class <className> #(parameter CORES = 3) extends uvm_sequence#(trace#(3));
    `uvm_object_utils(<className>#(3)
    localparam corewidth = $clog2(CORES);
    function new(string name = "<className>");
        super.new(name);
        `uvm_info("<CLASSID>", "<CLASSID> constructor", UVM_HIGH)
    endfunction

endclass
