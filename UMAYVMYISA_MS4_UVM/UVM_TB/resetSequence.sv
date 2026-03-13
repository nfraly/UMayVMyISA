class resetSequence #(parameter CORES = 3) extends uvm_sequence#(trace#(3));
    `uvm_object_utils(resetSequence#(3))
    localparam corewidth = $clog2(CORES);
    function new(string name = "resetSequence");
        super.new(name);
        `uvm_info("RSTSEQ", "RSTSEQ constructor", UVM_HIGH)
    endfunction

    trace#(3) tx;

    task body()
        reset();
    endtask

    task reset();
        trace#(3) tx = trace#(3)::type_id::create("tx");
        start_item(tx);
        assert(tx.randomize() with {rst == 1; opCode == 4'b0000;});
        `uvm_info("RSTSEQ", "Reset Sequence", UVM_HIGH)
        finish_item(tx);
    endtask

endclass
