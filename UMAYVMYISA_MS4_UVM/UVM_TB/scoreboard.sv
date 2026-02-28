class scoreboard extends uvm_test;

    `uvm_component_utils(scoreboard)

    uvm_analysis_imp #(trace#(3), scoreboard) scb_port;

    trace#(3) transactions[$];

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

    function void write(trace#(3) item);
        transactions.push_back(item);
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info("SCB_CLASS", "Run Phase", UVM_MEDIUM)

        forever begin

            trace#(3) testObject;
            wait((transactions.size() != 0));
            testObject = transactions.pop_front();
            compare(testObject); // checker 
        end
    endtask

    task compare(trace testObject);
        logic [7:0] actualAddr;
        logic [7:0] expectedAddr;

        case(testObject.opcode) 
            4'b0101: begin //Load 
               actualAddr = testObject.instr_word[27:23];
               expectedAddr = testObject.register;
            end
            4'b0110: begin //Store
                actualAddr = testObject.instr_word[27:23];
                expectedAddr = testObject.register;
            end
        endcase
    endtask



endclass



