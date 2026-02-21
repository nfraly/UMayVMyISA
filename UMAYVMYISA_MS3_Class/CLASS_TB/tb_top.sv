`include "interfaces.sv"
`include "rr_arbiter.sv"
`include "miu.sv"
`include "cache.sv"
`include "mem_arbiter.sv"
`include "memory.sv"
`include "mp_system.sv"

`include "tb_pkg.sv"
`include "environment.sv"

module tb_top;

  import tb_pkg::*;
  import system_widths_pkg::*;

  localparam int N = 3;

  logic clk;
  logic resetN;

  mp_system #(.N(N)) dut (
    .clk   (clk),
    .resetN(resetN)
  );

  initial clk = 0;
  always #5 clk = ~clk;

  task do_reset();
    resetN = 1'b0;
    repeat (5) @(posedge clk);
    resetN = 1'b1;
    repeat (2) @(posedge clk);
  endtask

  virtual iu_miu_if iu_vif [N];

  mem_env env;

  initial begin
    for (int i = 0; i < N; i++) begin
      iu_vif[i] = dut.iu2miu[i];
    end

    do_reset();

    env = new(N, iu_vif);
    env.num_transactions = 200;

    env.run();

    repeat (5000) @(posedge clk);

    env.sb.report();
    $finish;
  end

endmodule
