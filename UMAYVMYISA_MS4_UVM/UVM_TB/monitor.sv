class monitor extends uvm_monitor;
    `uvm_component_utils (monitor);

    virtual intf vif;

    uvm_analysis_port #(reg_item) mon_analysis_port;

    function new (string name = "monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase (uvm_phase phase);
        super.build_phase(phase);

        mon_analysis_port = new("mon_analaysis_port", this);

        if (!uvm_config_db #(virtual intf)::get(this, null, "vif" vif)) begin
            `uvm_fatal (get_type_name(), "Monitor interface not in db");
        end
    endfunction

    function void connect_phase (uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("mon_class", "connect_phase monitor", UVM_MEDIUM)
    endfunction

    virtual task run_phase (uvm_phase phase);
        super.run_phase(phase);
        trace testObj = trace::type_id::create("testObj");
        forever begin
            @(posedge vif.clk); //whatever signifies a new event
            testobj.inmembers = vif.inmembers; //grab the input for the DUT
            testobj.outmembers = vif.outmembers; //grab the DUT output

            mon_analysis_port.write(testObj);
        end
    endtask
endclass
