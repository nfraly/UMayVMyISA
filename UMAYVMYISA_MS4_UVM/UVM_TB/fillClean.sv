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
    logic [3:0] targ;
    int count;

    task body();
        for (targ = 0; targ < CORES; targ++) begin
            #10;
            fillCleanTask(targ);
        end
    endtask

    task fillCleanTask(logic [3:0] targ);
        for (i = 0; i < 8; i++) begin
            for (j = 0; j < 4; j++) begin
                trace#(3) tx = trace#(3)::type_id::create("tx");
                start_item(tx);
                assert(tx.randomize() with {rst == 0; opCode == 4'b0101; targetCore == targ; tag == j; index == i; offset == 2'b01;});
                count++;
                `uvm_info("FILLCLEAN", $sformatf("Generated a load instruction txcount %d",count), UVM_HIGH)
                finish_item(tx);
            end
        end
    endtask
endclass
