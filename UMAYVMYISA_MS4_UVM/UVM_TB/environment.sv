class env extends uvm_env;
    `uvm_component_utils(env);
    function new(string name = "env", uvm_component parent=null);
        super.new(name,parent);
    endfunction

   coreAgent a0;
   scoreboard s0;

   virtual function void build_phase(uvm_phase phase);
       super.build_phase(phase);
       a0 = coreAgent::type_id::create("a0", this);
       s0 = scoreboard::type_id::create("s0", this);
   endfunction

   virtual function void connect_phase(uvm_phase phase);
       super.connect_phase(phase);
       a0.m0.mon_analysis_port.connect(sb0.m_analysis_imp);
   endfunction

   task run_phase(uvm_phase phase);
       super.run_phase(phase);
   endtask


endclass
