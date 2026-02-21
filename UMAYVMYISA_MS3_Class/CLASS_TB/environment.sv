`include "tb_pkg.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor_in.sv"
`include "monitor_out.sv"
`include "scoreboard.sv"

import tb_pkg::*;
import system_widths_pkg::*;

class mem_env;
  int unsigned N;

  virtual iu_miu_if iu_vif [];

  mem_mbox_t gen2env;
  mem_mbox_t gen2drv [];

  mon_mbox_t mon_in;
  mon_mbox_t mon_out;

  mem_generator   gen;
  mem_driver      drv [];
  mem_monitor_in  min [];
  mem_monitor_out mout [];
  mem_scoreboard  sb;

  int unsigned num_transactions = 200;

  function new(int unsigned N, virtual iu_miu_if iu_vif[]);
    this.N = N;
    this.iu_vif = new[iu_vif.size()];
    for (int i=0;i<iu_vif.size();i++) this.iu_vif[i] = iu_vif[i];

    gen2env = new();
    mon_in  = new();
    mon_out = new();

    gen2drv = new[N];
    drv     = new[N];
    min     = new[N];
    mout    = new[N];

    for (int c = 0; c < int'(N); c++) begin
      gen2drv[c] = new();
      drv[c]  = new(c, this.iu_vif[c], gen2drv[c]);
      min[c]  = new(c, this.iu_vif[c], mon_in);
      mout[c] = new(c, this.iu_vif[c], mon_out);
    end

    gen = new(N, gen2env);
    gen.num_transactions = num_transactions;

    sb  = new(N, mon_in, mon_out);
  endfunction

  task dispatcher();
    mem_txn tr;
    forever begin
      gen2env.get(tr);
      if (tr.core_id >= N) begin
        $warning("ENV: clamping core_id %0d -> %0d", tr.core_id, (N>0)?(N-1):0);
        tr.core_id = (N>0)?(N-1):0;
      end
      gen2drv[tr.core_id].put(tr);
    end
  endtask

  task run();
    sb.run();

    for (int c = 0; c < int'(N); c++) begin
      fork
        min[c].run();
        mout[c].run();
      join_none
    end

    for (int c = 0; c < int'(N); c++) begin
      fork
        drv[c].run();
      join_none
    end

    fork
      dispatcher();
    join_none

    gen.run();
  endtask

endclass
