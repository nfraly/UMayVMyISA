// mp_wrapper.sv
// Wraps mp_system to expose a port interface
// Used to let the TB drive and observe per core transactions between IU and MIU
module mp_wrapper #(parameter int N = 3) (
  input logic clk,
  input logic resetN,
  iu_miu_if iu2miu [N]
);

  mp_system #(.N(N)) dut (
    .clk(clk),
    .resetN(resetN),
    .iu2miu(iu2miu)
  );

endmodule: mp_wrapper