class env extends uvm_env;
    `uvm_component_utils(env);

   coreAgent a0;
   scoreboard s0;

   coverage_mon c0;
   function new(string name = "env", uvm_component parent=null);
        super.new(name,parent);
        `uvm_info("ENV", "Environment Constructor", UVM_HIGH)
   endfunction


   function void build_phase(uvm_phase phase);
       super.build_phase(phase);
        `uvm_info("ENV", "Environment Build Phase", UVM_HIGH)
       a0 = coreAgent::type_id::create("a0", this);
       s0 = scoreboard::type_id::create("s0", this);
       c0 = coverage_mon::type_id::create("c0", this);

       //coverage needs to go here
   endfunction

   function void connect_phase(uvm_phase phase);
       super.connect_phase(phase);
        `uvm_info("ENV", "Environment Connect Phase", UVM_HIGH)
       a0.m0.mon_analysis_port.connect(s0.scb_port);

       a0.m0.mon_analysis_port.connect(c0.analysis_export);
       //coverage placeholder
   endfunction

   task run_phase(uvm_phase phase);
       super.run_phase(phase);
        `uvm_info("ENV", "Environment Run Phase", UVM_HIGH)
   endtask


endclass
