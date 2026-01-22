module top;

localparam N = 8;

bit rst, clk, extraZero, overflowCheck;

logic [N-1:0] w, x;
logic [(N*2)-1:0] f, expected, holder;
logic Cout;

logic [N-1:0] xQueue[$], wQueue[$];
logic [(N*2)-1:0] macHold[$];

int errorCount, testCase, i, j, overflowCount;


ece593w26_mac #(.N(N)) mac_dut (.clk(clk), .rst(rst), .w(w), .x(x), .f(f));

initial
  forever
    #5 clk = ~clk;

initial begin
 errorCount = '0;
 overflowCount = 0;
 testCase = 0;
 macHold.push_front(0);
 repeat (1) @(negedge clk) begin 
  rst = 1;
  expected = '0;
  w = '0;
  x = '0;
  end
  #20;
  repeat (1) @(negedge clk) rst = 0;
  $display("Test started!");
  #50;
  if (N <= 16) begin
    for (i = 0; i < (2**N); i++) begin
      for (j = 0; j < (2**N); j++) begin
        repeat (1) @(negedge clk) begin
          w = j;
          x = i;
          xQueue.push_front(i);
          wQueue.push_front(j);
        end
          macHold.push_front(x*w + macHold[0]);
        if(!extraZero) begin
          holder = macHold.pop_back();
          extraZero = 1;
        end
        #10;
        if(macHold.size() === N + 3) begin
         expected = macHold.pop_back(); 
          if (f !== expected) begin
           $display("Bad MAC operation! x: %b w: %b f: %b expected: %b mul2acc:%b",xQueue.pop_back() , wQueue.pop_back(), f, expected, mac_dut.mul2acc,);
           errorCount++;
          end
          else begin
          if (f[(2*N)-1]) 
            overflowCheck = 1;
          else if(!f[(2*N)-1] && overflowCheck) begin
            overflowCount++;
            overflowCheck = 0;
          end
          testCase++;
          end
          end
        end
    end
  while (macHold.size() !== 0) begin
    repeat(1) @(negedge clk);
    #10;
    expected = macHold.pop_back();
      if(expected === f) begin
        testCase++;
      end
          else if (f[(2*N)-1]) 
            overflowCheck = 1;
          else if (!f[(2*N)-1] && overflowCheck) begin
            overflowCount++;
            overflowCheck = 0;
          end
      else begin
           $display("Bad MAC operation! x: %b w: %b f: %b expected: %b mul2acc:%b", xQueue.pop_back(), wQueue.pop_back(), f, expected, mac_dut.mul2acc,);
      errorCount++;
      end
  end
  end    
  if (errorCount !== '0) 
    $display("Test failed! %d failed tests", errorCount);
  else if (overflowCount !== '0)
    $display("Overflow detected, MAC operation overflowed %d times",overflowCount);
  else
    $display("All test cases passed!");
$finish;
end
endmodule
    
