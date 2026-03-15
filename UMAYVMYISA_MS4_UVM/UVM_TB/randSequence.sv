class randSequence #(parameter CORES = 3) extends uvm_sequence#(trace#(3));
    `uvm_object_utils(randSequence#(3))
    localparam corewidth = $clog2(CORES);
    trace#(3) tx;
    function new(string name = "randSequence");
        super.new(name);
        `uvm_info("RANDSEQ", "RANDSEQ constructor", UVM_HIGH)
    endfunction

    task body();
        tx = trace#(3)::type_id::create("trace");

        start_item(tx);
        assert(tx.randomize() with {rst == 0;});
        finish_item(tx);
    endtask
endclass
