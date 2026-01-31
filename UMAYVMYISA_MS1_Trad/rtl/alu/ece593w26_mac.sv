module ece593w26_mac #(parameter N = 8)(
  input logic rst,
  input logic clk,
  input logic [N-1:0] w,
  input logic [N-1:0] x,
  output logic [(N*2)-1:0] f);


logic [N-1:0] w2mul, x2mul;
logic [(N*2)-1:0] mul2acc;
logic validOut;

always_ff @(posedge clk) begin
  if(rst) begin
    w2mul <= '0;
    x2mul <= '0;
  end
  else begin
    w2mul <= w;
    x2mul <= x;
  end
end

boothmul #(.WIDTH(N)) mul_dut (.w2mul(w2mul), .x2mul(x2mul), .clk(clk), .rst(rst), .mul2acc(mul2acc));

ece593w26_acc #(.N(N)) acc_dut (.mul2acc(mul2acc), .clk(clk), .rst(rst), .f(f));

endmodule
  
  

