class monitor extends uvm_monitor;
    `uvm_component_utils (monitor)

    virtual intf vif;
    trace#(3) testObj;
    bit core_capture_busy[0:2];

    uvm_analysis_port #(trace#(3)) mon_analysis_port;

    function new (string name = "monitor", uvm_component parent = null);
        super.new(name, parent);
        `uvm_info("MONITOR",  "Monitor Constructor", UVM_HIGH)
    endfunction

    virtual function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("MONITOR", "Monitor build phase", UVM_HIGH)
        mon_analysis_port = new("mon_analaysis_port", this);
        for (int c = 0; c < 3; ++c) begin
            core_capture_busy[c] = 1'b0;
        end

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
        `uvm_info("MONITOR", "Monitor run phase [MON_V_PERCORE_OVERLAP_20260313]", UVM_NONE)
        forever begin
            @(posedge vif.clk);
            `uvm_info("MONITOR", "Waiting for instr_ready", UVM_HIGH)
            if ((vif.instr_ready && vif.instr_valid && !vif.rst)) begin
                trace#(3) req;
                int core_idx;
                req = trace#(3)::type_id::create("req");
                if (req == null) begin
                    `uvm_fatal("MONITOR", "Failed to allocate trace object")
                end

                if ((^vif.instr_core_sel === 1'bx) || (vif.instr_core_sel >= 3)) begin
                    `uvm_error("MONITOR", $sformatf("Invalid instr_core_sel=%b at instr=0x%08h",
                        vif.instr_core_sel, vif.instr_word))
                    continue;
                end
                core_idx = int'(vif.instr_core_sel);

                req.instruction = vif.instr_word;
                req.opCode = vif.instr_word[31:28];
                req.targetCore = vif.instr_core_sel;
                `uvm_info("MONITOR", "instr_ready is high", UVM_HIGH)

               // if (core_capture_busy[core_idx]) begin
               //     `uvm_error("MONITOR", $sformatf(
               //         "Per-core monitor worker overlap core=%0d instr=0x%08h",
               //         core_idx, req.instruction))
               //     continue;
               // end

                core_capture_busy[core_idx] = 1'b1;
                fork
                    automatic trace#(3) testObj = req;
                    automatic int worker_core_idx = core_idx;
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
                            (4'b1101): begin //all ALU op codes; 6 cycles (1 cycle after instruction grab operands, 5 cycles later we are done and can grab result)
                                `uvm_info("MONITOR", $sformatf("Found an ALU op code, instr_ready is %b", vif.instr_ready), UVM_HIGH)
                                @(posedge vif.clk);
                                core_capture_busy[core_idx] = '0;
                                testObj.aluA = vif.core_rf_rdata_a_dbg[worker_core_idx];
                                testObj.aluB = vif.core_rf_rdata_b_dbg[worker_core_idx];
                                repeat (5) @(posedge vif.clk);
                                testObj.result = vif.core_rf_wdata_dbg[worker_core_idx];
                            end
                            (4'b0101): begin //LOAD - 11 cycles for hit, 27 on clean miss, 39 on a dirty miss
                                bit got_addr = 0;
                                int cyc = 0;

                                forever begin
                                    @(posedge vif.clk);
                                    cyc++;
                                    `uvm_info("MONITOR", $sformatf("bus shows address %b", vif.core_iu_mem_addr_dbg[worker_core_idx]), UVM_HIGH)

                                    if (!got_addr && vif.core_iu_mem_req_dbg[testObj.targetCore] && !vif.core_iu_mem_we_dbg[testObj.targetCore]) begin
                                        testObj.address = vif.core_iu_mem_addr_dbg[testObj.targetCore];
                                        got_addr = 1'b1;
                                    end
                                    if (vif.core_rf_wen_dbg[testObj.targetCore]) begin
                                        testObj.result = vif.core_rf_wdata_dbg[testObj.targetCore];
                                        testObj.register = vif.core_rf_waddr_dbg[testObj.targetCore];
                                        `uvm_info("MONITOR", $sformatf("Found a LOAD opcode, sending data %X and register %d to scoreboard", testObj.result, testObj.register), UVM_HIGH)
                                        `uvm_info("MONITOR", $sformatf("Load instruction: Register = %d Address = %h Instruction = %h",testObj.register, testObj.address, testObj.instruction), UVM_MEDIUM)
                                        break;
                                    end
                                    if (cyc > 120) begin
                                        `uvm_error("MONITOR", $sformatf("LOAD timeout core=%0d instr=0x%08h", testObj.targetCore, testObj.instruction))
                                        break;
                                    end
                                end
                            end
                            (4'b0110): begin //STORE - 12 cycles for hit, 23 clean miss, 35 on a dirty miss
                                bit got_addr = 0;
                                int cyc = 0;

                                testObj.address = 'x;

                                forever begin
                                    @(posedge vif.clk);
                                    cyc++;
                                    `uvm_info("MONITOR", $sformatf("bus shows address %b", vif.core_iu_mem_addr_dbg[worker_core_idx]), UVM_HIGH)

                                    if (!got_addr && vif.core_iu_mem_req_dbg[worker_core_idx] && vif.core_iu_mem_we_dbg[worker_core_idx]) begin
                                        testObj.address = vif.core_iu_mem_addr_dbg[worker_core_idx];
                                        testObj.memData = vif.core_iu_mem_wdata_dbg[worker_core_idx];
                                        `uvm_info("MONITOR", $sformatf("Grabbing address %b and data %d to scoreboard", testObj.address, testObj.memData), UVM_HIGH)
                                        got_addr = 1'b1;
                                    end
                                    if (got_addr && (vif.core_iu_mem_done_dbg[worker_core_idx] || !vif.core_iu_mem_req_dbg[worker_core_idx])) begin
                                        `uvm_info("MONITOR", $sformatf("Found a STORE opcode, sending address %X and data %d to scoreboard", testObj.address, testObj.memData), UVM_HIGH)
                                        `uvm_info("MONITOR", $sformatf("Store instruction: Register = %d Address = %h Instruction = %h",testObj.instruction[27:23], testObj.address, testObj.instruction), UVM_MEDIUM)
                                        break;
                                    end
                                    if (cyc > 120) begin
                                        `uvm_error("MONITOR", $sformatf("STORE timeout core=%0d instr=0x%08h", testObj.targetCore, testObj.instruction))
                                        break;
                                    end
                                end
                            end
                            default:
                                repeat (4) @(posedge vif.clk);
                        endcase
                        mon_analysis_port.write(testObj);
                        core_capture_busy[worker_core_idx] = 1'b0;
                    end
                join_none
            end
        end
    endtask
endclass
