class env extends uvm_env;
    `uvm_component_utils(env);

   coreAgent a0;
   scoreboard s0;
   function new(string name = "env", uvm_component parent=null);
        super.new(name,parent);
   endfunction


   function void build_phase(uvm_phase phase);
       super.build_phase(phase);
       a0 = coreAgent::type_id::create("a0", this);
       s0 = scoreboard::type_id::create("s0", this);

       //coverage needs to go here
   endfunction

   function void connect_phase(uvm_phase phase);
       super.connect_phase(phase);
       a0.m0.mon_analysis_port.connect(s0.scb_port);
       //coverage placeholder
   endfunction

   task run_phase(uvm_phase phase);
       super.run_phase(phase);
   endtask


endclass
