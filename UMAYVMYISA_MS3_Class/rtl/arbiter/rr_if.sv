// rr_if.sv
interface rr_if #(parameter int N = 3) (input logic clk);
  logic resetN; // active low
  logic [N-1:0] req;
  logic [N-1:0] grant;
endinterface