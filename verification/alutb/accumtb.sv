module top;

localparam N = 4;

bit clk, rst;

logic [(N*2)-1:0] mul2acc;
logic carryBit, carryHold, inputValid;
logic [(N*2)-1:0] f, expected;
logic [(N*2)-1:0] holder;

int i, j;

ece593w26_acc #(.N(N)) dut (.mul2acc(mul2acc), .rst(rst), .clk(clk), .Cout(carryBit), .f(f));

initial
  forever 
    #5 clk = ~clk;

initial begin
repeat (1) @(negedge clk) begin
 rst = 1;
 mul2acc = '0;
 holder = '0;
end
#20;
repeat (1) @(negedge clk) rst = 0;

#20;
$display("Test started!");

for (i = 0; i < 2**(N*2); i++) begin
  repeat(1) @(negedge clk) begin
    mul2acc = i;
  end
  #10;
  {carryHold, expected} = mul2acc + holder;
  if ({carryHold,expected} === {carryBit, f}) begin
   j = j; 
  end
  else begin
      $display("Bad accumulation value A %b + B %b gives %b with carry %b", mul2acc, holder, f, carryBit);
    j++;
  end
  holder = f;
end
if (j !== 0)
  $display("Test failed! %d test cases failed",j);
else
  $display("Test passed!");
$finish;
end

endmodule
