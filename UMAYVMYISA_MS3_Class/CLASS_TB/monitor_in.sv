`include "tb_pkg.sv"

import tb_pkg::*;
import system_widths_pkg::*;

class mem_monitor_in;
  virtual iu_miu_if vif;
  int unsigned      core_id;

  mon_mbox_t mon2sb_in;

  function new(int unsigned core_id, virtual iu_miu_if vif, mon_mbox_t mon2sb_in);
    this.core_id   = core_id;
    this.vif       = vif;
    this.mon2sb_in = mon2sb_in;
  endfunction

  task run();
    mem_txn tr;

    forever begin
      @(posedge vif.clk);

      if (vif.mem_req === 1'b1) begin
        tr = new();
        tr.core_id = core_id;
        tr.we      = vif.mem_we;
        tr.addr    = vif.mem_addr;
        tr.wdata   = vif.mem_write;
        tr.start_time = $time;
        mon2sb_in.put(tr);
      end
    end
  endtask
endclass
