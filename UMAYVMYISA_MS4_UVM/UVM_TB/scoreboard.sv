class scoreboard extends uvm_test;

    `uvm_component_utils(scoreboard)

    uvm_analysis_imp #(trace#(3), scoreboard) scb_port;

    trace transactions[$];

    function new(string name = "scoreboard", uvm_component parent);
        super.new(name, parent);
        `uvm_info("SCB_CLASS", "Inside Constructor", UVM_MEDIUM)
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        scb_port = new("scb_port", this);
        `uvm_info("SCB_CLASS", "Build Phase", UVM_MEDIUM)
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("SCB_CLASS", "Connect Phase", UVM_MEDIUM)
    endfunction

    function void write(trace item);
        transactions.push_back(item);
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info("SCB_CLASS", "Run Phase", UVM_MEDIUM)

        forever begin

            trace curr_trans;
            wait((transactions.size() != 0));
            curr_trans = transactions.pop_front();
    //        compare(curr_trans); // checker 
        end
    endtask

endclass



