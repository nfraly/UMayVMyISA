class monitor extends uvm_monitor;
    `uvm_component_utils (monitor)

    virtual intf vif;
    trace#(3) testObj;

    uvm_analysis_port #(trace#(3)) mon_analysis_port;

    function new (string name = "monitor", uvm_component parent = null);
        super.new(name, parent);
        `uvm_info("MONITOR",  "Monitor Constructor", UVM_HIGH)
    endfunction

    virtual function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("MONITOR", "Monitor build phase", UVM_HIGH)
        mon_analysis_port = new("mon_analaysis_port", this);

        if(!(uvm_config_db #(virtual intf)::get(this, "*", "vif", vif))) begin
            `uvm_error("MONITOR", "Failed to get VIF from config DB")
        end
    endfunction

    function void connect_phase (uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("MONITOR", "Monitor connect phase", UVM_MEDIUM)
    endfunction



     task run_phase (uvm_phase phase);
        super.run_phase(phase);
        `uvm_info("MONITOR", "Monitor run phase", UVM_HIGH)
        testObj = trace#(3)::type_id::create("testObj");
        forever begin
            while(!(vif.instr_ready)) @(posedge vif.clk);
            case(vif.instr_word[31:28])
                (ADD),
                (AND),
                (SUB),
                (MUL),
                (SHR),
                (SHL),
                (SP1),
                (SP2),
                (SP3),
                (SP4),
                (SP5): begin
                    repeat (6) @(posedge vif.clk);
                    testObj.opcode <= vif.instr_word[31:28];
                    testObj.aluA <= vif.core_rf_rdata_a_dbg;
                    testObj.aluB <= vif.core_rf_rdata_b_dbg;
                    testObj.result <= vif.core_alu_result_dbg;
                end
                (LD): begin
                    repeat (11) @(posedge vif.clk);
                    testObj.memData <= vif.mem_dbg_data;
                    testObj.address <= vif.mem_dbg_addr;
                    testObj.register <= vif.mem_req_addr_dbg;
                end
                (STR): begin
                    repeat (12) @(posedge vif.clk);
                    //TODO
                end
            endcase

            mon_analysis_port.write(testObj);
        end
    endtask
endclass
