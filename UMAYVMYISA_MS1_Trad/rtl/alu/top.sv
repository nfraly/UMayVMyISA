module top;

parameter WIDTH = 8;

logic signed [7:0] w2mul, x2mul;
logic signed [15:0] mul2acc;

bit clk, rst;

boothmul #(.WIDTH(WIDTH)) dut (.w2mul(w2mul), .x2mul(x2mul), .mul2acc(mul2acc), .clk(clk), .rst(rst));


initial forever #5 clk = ~clk;

initial begin
    rst = '1;
    repeat(2) @(negedge clk);
    rst = '0;
    x2mul = -8'd5;
    w2mul = 8'd8;
    $display("%0d times %0d equals %0d at time %t", x2mul, w2mul, $signed(mul2acc), $time);
    repeat(1) @(negedge clk);
    $display("%0d times %0d equals %0d at time %t", x2mul, w2mul, $signed(mul2acc), $time);
    repeat(1) @(negedge clk);
    $display("%0d times %0d equals %0d at time %t", x2mul, w2mul, $signed(mul2acc), $time);
    repeat(1) @(negedge clk);
    $display("%0d times %0d equals %0d at time %t", x2mul, w2mul, $signed(mul2acc), $time);
    repeat(1) @(negedge clk);
    rst = '1;
    $display("%0d times %0d equals %0d at time %t", x2mul, w2mul, $signed(mul2acc), $time);
    repeat(1) @(negedge clk);
    $display("%0d times %0d equals %0d at time %t", x2mul, w2mul, $signed(mul2acc), $time);
    $finish;
end
    
endmodule
