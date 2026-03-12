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
        `uvm_info("MONITOR", "Monitor connect phase", UVM_HIGH)
    endfunction



     task run_phase (uvm_phase phase);
        super.run_phase(phase);
        `uvm_info("MONITOR", "Monitor run phase", UVM_HIGH)
        forever begin
            @(posedge vif.clk);
            //`uvm_info("MONITOR", "Waiting for instr_ready", UVM_HIGH)
            if ((vif.instr_ready && vif.instr_valid && !vif.rst)) begin
            trace#(3) req;
            req = trace#(3)::type_id::create("req");
            req.instruction = vif.instr_word;
            req.opCode = vif.instr_word[31:28];
            req.targetCore = vif.instr_core_sel;
            `uvm_info("MONITOR", "instr_ready is high", UVM_HIGH)
            fork
                automatic trace#(3) testObj = req;
                begin
            case(testObj.opCode)
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
                    `uvm_info("MONITOR", $sformatf("Found an ALU op code, instr_ready is %b", vif.instr_ready), UVM_HIGH)
                    @(posedge vif.clk);
                    testObj.aluA = vif.core_rf_rdata_a_dbg[testObj.targetCore];
                    testObj.aluB = vif.core_rf_rdata_b_dbg[testObj.targetCore];
                    repeat (5) @(posedge vif.clk);
                    testObj.result = vif.core_rf_wdata_dbg[testObj.targetCore];
                    //`uvm_info("MONITOR", $sformatf("Sending tx to scoreboard %p", testObj), UVM_HIGH)
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
                default:
                    repeat (4) @(posedge vif.clk);
            endcase
            //`uvm_info("MONITOR", $sformatf("Sending tx to scoreboard %p", testObj), UVM_HIGH)
            mon_analysis_port.write(testObj);
        end
    join_none
        end
    end
    endtask
endclass
