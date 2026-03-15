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
  	  for (int r = 1; r < 32; r++) begin
    	    primeStoreReg(targ, r[4:0], r[10:0]);
  	  end
  	  fill(targ);
	end




        //for (targ = 0; targ < CORES; targ++) begin
	 //   primeStoreReg(targ, r[4:0], r[10:0]);
	    //primeStoreReg(targ, 5'd1, 11'h000);
	    //primeStoreReg(targ, 5'd2, 11'h001);
	    //primeStoreReg(targ, 5'd3, 11'h002);
	    //primeStoreReg(targ, 5'd4, 11'h003);
          //  fill(targ);
       // end


        `uvm_info("DRTFIL", "Made cache dirty", UVM_MEDIUM)
    endtask

    // 
    task primeStoreReg(logic [corewidth-1:0] target, logic [4:0] reg_id, logic [10:0] addr11);
        trace#(3) tx = trace#(3)::type_id::create("tx");
        logic [5:0] t;
        logic [2:0] idx;
        logic [1:0] off;
        t = addr11[10:5];
        idx = addr11[4:2];
        off = addr11[1:0];
        start_item(tx);
        assert(tx.randomize() with {
            rst == 0; opCode == 4'b0101; targetCore == target;
            rt == reg_id; tag == t; index == idx; offset == off;
        });
        finish_item(tx);
    endtask

    task fill(logic [corewidth-1:0] target);
        for (i=0; i < 8; i++) begin
            for (j=0; j < 4; j++) begin
                trace#(3) tx = trace#(3)::type_id::create("tx");
                start_item(tx);
                assert(tx.randomize() with {rst == 0; opCode == 4'b0110; index == i; tag == j; targetCore == target; rt inside {[5'd1:5'd31]}; offset inside {2'b00, 2'b01, 2'b10, 2'b11};}); // will remove offset after initial tests passed 
                finish_item(tx);
            end
        end
    endtask

endclass
