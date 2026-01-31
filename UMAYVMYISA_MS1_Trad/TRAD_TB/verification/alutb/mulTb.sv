module top;

localparam N = 4;

bit clk, rst;

logic [N-1:0] w2mul, x2mul;
logic [(N*2)-1:0] mul2acc;
int i, j, errorCount;
logic [(N*2)-1:0] mulHold [$];
logic [(N*2)-1:0] mulCurr;
bit pipelinefill;
logic [N-1:0] xQueue [$];
logic [N-1:0] wQueue [$];

int testcases;

boothmul #(.WIDTH(N)) mul_dut (.w2mul(w2mul), .x2mul(x2mul), .clk(clk), .rst(rst), .mul2acc(mul2acc));


initial
  forever 
    #5 clk = ~clk;


initial begin
errorCount = 0;
  repeat (1) @(negedge clk) begin
    rst = 1;
    w2mul = '0;
    x2mul = '0;
  end
  #20;
  repeat (1) @(negedge clk) rst = 0;
  $display("Test started!");
  if (N <= 8) begin
    for (i = 0; i < 2**N; i++) begin
      for (j = 0; j < 2**N; j++) begin
        repeat (1) @(negedge clk) begin
        x2mul = i;
        w2mul = j;
	xQueue.push_front(i);
	wQueue.push_front(j);
        end
        mulHold.push_front(x2mul * w2mul);
       /* if(pipelinefill) begin
          $display("Waiting for pipeline");
          #((N+2) * 10);
          pipelinefill = 1;
        end*/
      
        //else if (pipelinefill) 
          //#((N+1)*10);
          #10;
	if (mulHold.size() === N + 1) begin
		mulCurr = mulHold.pop_back(); 
       		if (mulCurr === mul2acc) begin
          		errorCount = errorCount;
          		testcases++;
          		$display("x:%b w:%b f:%b expected:%b",xQueue.pop_back(), wQueue.pop_back(), mul2acc, mulCurr);
        		end
        	else begin
          		$display("Bad multiply product, %b * %b gives %b expected %b ", xQueue.pop_back(), wQueue.pop_back(), mul2acc, mulCurr);
        		errorCount++;
        		end
		end
      	end
	end
	while(mulHold.size() !== 0) begin 
	repeat(1) @(negedge clk);
	#10;
	mulCurr = mulHold.pop_back(); 
       		if (mulCurr === mul2acc) begin
          		errorCount = errorCount;
          		testcases++;
          		$display("x:%b w:%b f:%b expected:%b",xQueue.pop_back(), wQueue.pop_back(), mul2acc, mulCurr);
        		end
        	else begin
          		$display("Bad multiply product, %b * %b gives %b expected %b ", xQueue.pop_back(), wQueue.pop_back(), mul2acc, mulCurr);
        		errorCount++;
        		end
		end

	
end
if (errorCount !== 0)
  $display("Test failed! %d test cases failed", errorCount);
else
  $display("Test passed! %d tests passed", testcases);
$finish;
end
endmodule

  

    
