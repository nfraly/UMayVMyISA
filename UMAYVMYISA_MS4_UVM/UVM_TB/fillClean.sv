class fillClean #(parameter CORES = 3) extends uvm_sequence#(trace#(3));
    `uvm_object_utils(fillClean#(3))
    localparam corewidth = $clog2(CORES);
    function new(string name = "fillClean");
        super.new(name);
        `uvm_info("FILLCLEAN", "FILLCLEAN constructor", UVM_HIGH)
    endfunction


    trace#(3) tx;

    logic [3:0] i;
    logic [3:0] j;
    int targ;

    task body();
        for (targ = 0; targ < CORES; targ++) begin
            fillCleanTask(targ);
        end
    endtask

    task fillCleanTask(int targ);
        for (i = 0; i < 8; i++) begin
            for (j = 0; j < 4; j++) begin
                trace#(CORES) tx = trace#(CORES)::type_id::create("tx");
                start_item(tx);
                assert(tx.randomize() with {rst == 0; opCode == 4'b0101; targetCore == targ; tag == j; index == i; offset == 2'b01;});
                `uvm_info("FILLCLEAN", "Generated a load instruction", UVM_HIGH)
                finish_item(tx);
            end
        end
    endtask
endclass
