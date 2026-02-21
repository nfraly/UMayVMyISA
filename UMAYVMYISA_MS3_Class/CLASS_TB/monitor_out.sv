`include "tb_pkg.sv"

import tb_pkg::*;
import system_widths_pkg::*;

class mem_monitor_out;
  virtual iu_miu_if vif;
  int unsigned      core_id;

  mon_mbox_t mon2sb_out;

  function new(int unsigned core_id, virtual iu_miu_if vif, mon_mbox_t mon2sb_out);
    this.core_id    = core_id;
    this.vif        = vif;
    this.mon2sb_out = mon2sb_out;
  endfunction

  task run();
    mem_txn tr;

    forever begin
      @(posedge vif.clk);

      if (vif.mem_done === 1'b1) begin
        tr = new();
        tr.core_id = core_id;
        tr.rdata   = vif.mem_read;
        tr.done_time = $time;
        mon2sb_out.put(tr);
      end
    end
  endtask
endclass
