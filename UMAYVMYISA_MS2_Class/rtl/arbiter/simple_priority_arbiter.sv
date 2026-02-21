// simple_priority_arbiter.sv
module simple_priority_arbiter #(parameter int N = 3) (
  input logic [N-1:0] Req,
  output logic [N-1:0] Grant
);

  always_comb begin
    Grant = '0;

    for (int i = 0; i < N; i++) begin
      if (Req[i]) begin
        Grant[i] = 1'b1;
        break;
      end
    end
  end
endmodule