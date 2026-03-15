class scoreboard extends uvm_scoreboard;

    `uvm_component_utils(scoreboard)

    uvm_analysis_imp #(trace#(3), scoreboard) scb_port;

    trace#(3) transactions[$];
    localparam int ADDR_W = 11;
    localparam int MEM_DEPTH = (1 << ADDR_W);
    logic [7:0] shadow_mem [0:MEM_DEPTH-1];
    bit shadow_valid [0:MEM_DEPTH-1];

    function bit has_x8(logic [7:0] v);
        return ((^v) === 1'bx);
    endfunction

    function new(string name = "scoreboard", uvm_component parent);
        super.new(name, parent);
        `uvm_info("SCB_CLASS", "Inside Constructor", UVM_HIGH)
    endfunction

    function void build_phase(uvm_phase phase);
	string init_path;
        super.build_phase(phase);
        scb_port = new("scb_port", this);
        for (int i = 0; i < MEM_DEPTH; ++i) begin
            shadow_mem[i] = '0;
            shadow_valid[i] = 1'b1; //adjusting 1'b0 to all bits set
        end

	if (!$value$plusargs("INIT_MEM_FILE=%s", init_path)) init_path = "../rtl/init_memory";

	$readmemh(init_path, shadow_mem);
        `uvm_info("SCB_CLASS", "Build Phase", UVM_HIGH)
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("SCB_CLASS", "Connect Phase", UVM_HIGH)
    endfunction

    function void write(trace#(3) item);
        transactions.push_back(item);
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info("SCB_CLASS", "Run Phase", UVM_HIGH)

        forever begin

            trace#(3) testObject;
            wait((transactions.size() != 0));
            testObject = transactions.pop_front();
            `uvm_info("SCB_CLASS", "Grabbing tx from Monitor", UVM_HIGH)
            compare(testObject); // checker 
            //TODO: ADD LOGIC FOR WAITING FOR ALL INSTRUCTIONS TO CLEAR
        end
    endtask

    task compare(trace#(3) testObject);
        logic [31:0] actual;
        logic [31:0] expected;
        logic [31:0] A, B;

        case(testObject.opCode) 
            4'b0000: begin//NOP
                `uvm_info("Compare", "See a NOP", UVM_HIGH)
            end
            4'b0001: begin//ADD
                A=testObject.aluA;
                B=testObject.aluB;
                expected = A+B;
                actual = testObject.result;
            end
            4'b0010: begin//AND
                A=testObject.aluA;
                B=testObject.aluB;
                expected = A&B;
                actual = testObject.result;
            end
            4'b0011: begin//SUB
                A=testObject.aluA;
                B=testObject.aluB;
                expected = A-B;
                actual = testObject.result;
            end
            4'b0100: begin//MUL
                A=testObject.aluA;
                B=testObject.aluB;
                expected = A*B;
                actual = testObject.result;
            end
            4'b0101: begin //Load
                logic [10:0] load_addr;
                logic [4:0] exp_rd;
                logic [4:0] act_rd;
                logic [7:0] act_data;
                logic [7:0] exp_data;

                exp_rd = testObject.instruction[27:23];
                act_rd = testObject.register;
                load_addr = testObject.instruction[10:0];
                act_data = testObject.result[7:0];

                if (act_rd !== exp_rd) begin
                    `uvm_error("Compare", $sformatf("LOAD rd mismatch core=%0d addr=0x%03h actual_rd=%0d expected_rd=%0d",
                        testObject.targetCore, load_addr, act_rd, exp_rd))
                    return;
                end


                if (!shadow_valid[load_addr]) begin
		            `uvm_info("Compare", $sformatf("LOAD addr 0x%03h has no prior STORE in shadow model; skipping data compare", load_addr), UVM_HIGH)
                    return;
                end

                if (has_x8(act_data)) begin
                    `uvm_error("Compare", $sformatf("LOAD data has X core=%0d addr=0x%03h data=%h",
                        testObject.targetCore, load_addr, act_data))
                    return;
                end

                exp_data = shadow_mem[load_addr];
                if (act_data !== exp_data) begin
                    `uvm_error("Compare", $sformatf("LOAD data mismatch core=%0d addr=0x%03h register=%d actual=%02h expected=%02h instruction=%0h tag=%0h index=%0h offest=%0h",
                        testObject.targetCore, load_addr, act_rd, act_data, exp_data, testObject.instruction, load_addr[10:5], load_addr[4:2], load_addr[1:0]))
                end
                else begin
                    `uvm_info("Compare", $sformatf("LOAD data pass core=%0d addr=0x%03h data=%02h",
                        testObject.targetCore, load_addr, act_data), UVM_HIGH)
                end
                return;
            end
            4'b0110: begin //Store
                logic [10:0] exp_addr;
                logic [10:0] act_addr;
                logic [7:0] store_data;

                exp_addr = testObject.instruction[10:0];
                act_addr = testObject.address[10:0];
                store_data = testObject.memData[7:0];

                if (act_addr !== exp_addr) begin
                    `uvm_error("Compare", $sformatf("STORE addr mismatch core=%0d actual=0x%03h expected=0x%03h",
                        testObject.targetCore, act_addr, exp_addr))
                    return;
                end

                if (has_x8(store_data)) begin
                    `uvm_error("Compare", $sformatf("STORE data has X core=%0d addr=0x%03h data=%h tag=0x%06h index=0x%03h offset=0x%02h",
                        testObject.targetCore, act_addr, store_data, act_addr[10:5], act_addr[4:2], act_addr[1:0]))
                    return;
                end

                shadow_mem[act_addr] = store_data;
                shadow_valid[act_addr] = 1'b1;
                `uvm_info("Compare", $sformatf("STORE model update core=%0d addr=0x%03h data=%02h",
                    testObject.targetCore, act_addr, store_data), UVM_HIGH)
                return;
            end
            4'b0111: begin//RS
                A=testObject.aluA;
                expected = A >> 1'b1;
                actual = testObject.result;
            end
            4'b1000: begin//LS
                A=testObject.aluA;
                expected = A << 1'b1;
                actual = testObject.result;
            end
            4'b1001: begin//AB-A
                A=testObject.aluA;
                B=testObject.aluB;
                expected = A*B-A;
                actual = testObject.result;
            end
            4'b1010: begin//A*4*B-A
                A=testObject.aluA;
                B=testObject.aluB;
                expected = A*4*B-A;
                actual = testObject.result;
            end
            4'b1011: begin//AB+A
                A=testObject.aluA;
                B=testObject.aluB;
                expected = A*B+A;
                actual = testObject.result;
            end
            4'b1100: begin//3A
                A=testObject.aluA;
                expected = 3*A;
                actual = testObject.result;
            end
            4'b1101: begin//AB+B
                A=testObject.aluA;
                B=testObject.aluB;
                expected = A*B+B;
                actual = testObject.result;
            end
            4'b1110: begin//MVI?
            end
            4'b1111: begin//Dump?
            end
        endcase
        if (actual !== expected) begin
            `uvm_error("Compare", $sformatf("Transaction failed! opCode: %b Actual %b expected %b", testObject.opCode ,actual, expected))
        end
        else begin
            `uvm_info("Compare", $sformatf("Transaction passed: Actual: %b Expected: %b", actual, expected), UVM_HIGH)
        end
    endtask
        

endclass



