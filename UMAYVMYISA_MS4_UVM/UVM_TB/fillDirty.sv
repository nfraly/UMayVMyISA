class fillDirty #(parameter CORES = 3) extends uvm_sequence#(trace#(3));
    `uvm_object_utils(fillDirty#(3))
    localparam corewidth = $clog2(CORES);
    function new(string name = "fillDirty");
        super.new(name);
        `uvm_info("DRTFIL", "DRTFIL constructor", UVM_HIGH)
    endfunction

    logic [3:0] i;
    logic [3:0] j;
    logic [corewidth:0] targ;

    task body();
        `uvm_info("DRTFIL", "Making cache dirty", UVM_MEDIUM)
        for (targ = 0; targ < CORES; targ++) begin
            fill(targ);
        end
        `uvm_info("DRTFIL", "Made cache dirty", UVM_MEDIUM)
    endtask

    task fill(logic [corewidth-1:0] target);
        for (i=0; i < 8; i++) begin
            for (j=0; j < 4; j++) begin
                trace#(3) tx = trace#(3)::type_id::create("tx");
                start_item(tx);
                assert(tx.randomize() with {rst == 0; opCode == 4'b0110; index == i; tag == j; targetCore == target;});
                finish_item(tx);
            end
        end
    endtask

endclass
