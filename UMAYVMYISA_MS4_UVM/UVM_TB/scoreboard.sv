class scoreboard extends uvm_test;

    `uvm_component_utils(scoreboard)

    uvm_analysis_imp #(trace#(3), scoreboard) scb_port;

    trace#(3) transactions[$];

    function new(string name = "scoreboard", uvm_component parent);
        super.new(name, parent);
        `uvm_info("SCB_CLASS", "Inside Constructor", UVM_HIGH)
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        scb_port = new("scb_port", this);
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
        end
    endtask

    task compare(trace#(3) testObject);
        logic [31:0] actual;
        logic [31:0] expected;
        logic [31:0] A, B;

        case(testObject.opCode) 
            4'b0000: begin//NOP
                //confirm nothing happens somehow?
            end
            4'b0001: begin//ADD
                A=testObject.aluA;
                B=testObject.aluB;
                expected = A+B;
            end
            4'b0010: begin//AND
                A=testObject.aluA;
                B=testObject.aluB;
                expected = A&B;
            end
            4'b0011: begin//SUB
                A=testObject.aluA;
                B=testObject.aluB;
                expected = A-B;
            end
            4'b0100: begin//MUL
                A=testObject.aluA;
                B=testObject.aluB;
                expected = A*B;
            end
            4'b0101: begin //Load 
               actual = testObject.instruction[27:23];
               expected = testObject.register;
            end
            4'b0110: begin //Store
                actual = testObject.instruction[27:23];
                expected = testObject.register;
            end
            4'b0111: begin//RS
                A=testObject.aluA;
                expected = A >> 1'b1;
            end
            4'b1000: begin//LS
                A=testObject.aluA;
                expected = A << 1'b1;
            end
            4'b1001: begin//AB-A
                A=testObject.aluA;
                B=testObject.aluB;
                expected = A*B-A;
            end
            4'b1010: begin//A*4*B-A
                A=testObject.aluA;
                B=testObject.aluB;
                expected = A*4*B-A;
            end
            4'b1011: begin//AB+A
                A=testObject.aluA;
                B=testObject.aluB;
                expected = A*B+A;
            end
            4'b1100: begin//3A
                A=testObject.aluA;
                expected = 3*A;
            end
            4'b1101: begin//AB+B
                A=testObject.aluA;
                B=testObject.aluB;
                expected = A*B+B;
            end
            4'b1110: begin//MVI?
            end
            4'b1111: begin//Dump?
            end
        endcase
        if (actual != expected) begin
            `uvm_error("Compare", $sformatf("Transaction failed! Actual %b expected %b", actual, expected))
        end
        else begin
            `uvm_info("Compare", "Transaction passed", UVM_HIGH)
        end
    endtask
        

endclass



