module ece593w26_acc #(parameter N = 8)(
input logic [(N*2)-1:0] mul2acc,
input logic rst,
input logic clk,
output logic [(N*2)-1:0] f);


logic [(N*2):0] Carry;

logic carryBit;

logic [(N*2)-1:0] d;

assign Carry[0] = 1'b0;
assign carryBit = Carry[N*2];

//Full Adder instantiation
generate 
genvar i;

for (i=0; i < N*2; i++) begin
 fullAdder dut0 (.A(mul2acc[i]), .B(f[i]), .Cin(Carry[i]), .Cout(Carry[i+1]), .Sum(d[i]));
end
endgenerate

always_ff @(posedge clk) begin
if (rst) begin
  f <= '0;
end
else begin
  f <= d;
end
end
endmodule
