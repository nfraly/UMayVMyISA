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
        `uvm_info("MONITOR", "Monitor run phase", UVM_MEDIUM)
        testObj = trace#(3)::type_id::create("testObj");
        forever begin
            `uvm_info("MONITOR", "Waiting for instr_ready", UVM_NONE)
            wait((vif.instr_ready));
            `uvm_info("MONITOR", "instr_ready is low", UVM_NONE)
            case(vif.instr_word[31:28])
                (4'b0001),
                (4'b0010),
                (4'b0011),
                (4'b0100),
                (4'b0111),
                (4'b1000),
                (4'b1001),
                (4'b1010),
                (4'b1011),
                (4'b1100),
                (4'b1101): begin
                    repeat (6) @(posedge vif.clk);
                    testObj.opCode <= vif.instr_word[31:28];
                    testObj.aluA <= vif.core_rf_rdata_a_dbg;
                    testObj.aluB <= vif.core_rf_rdata_b_dbg;
                    testObj.result <= vif.core_alu_result_dbg;
                    `uvm_info("MONITOR", "Sending an ALU op to scoreboard", UVM_HIGH)
                end
                (4'b0101): begin
                    repeat (11) @(posedge vif.clk);
                    testObj.memData <= vif.mem_dbg_data;
                    testObj.address <= vif.mem_dbg_addr;
                    testObj.register <= vif.mem_req_addr_dbg;
                end
                (4'b0110): begin
                    repeat (12) @(posedge vif.clk);
                    //TODO
                end
            endcase

            mon_analysis_port.write(testObj);
        end
    endtask
endclass
