`include "tb_pkg.sv"

import tb_pkg::*;
import system_widths_pkg::*;

class mem_driver;

  virtual iu_miu_if.iu vif;

  int unsigned core_id;
  mem_mbox_t   gen2drv;

  function new(int unsigned core_id,
               virtual iu_miu_if.iu vif,
               mem_mbox_t gen2drv);
    this.core_id = core_id;
    this.vif     = vif;
    this.gen2drv = gen2drv;
  endfunction

  task reset_signals();
    if (vif == null) begin
      $fatal(1, "DRIVER%0d: vif is NULL (virtual interface not bound)", core_id);
    end

    vif.mem_req   <= 1'b0;
    vif.mem_we    <= 1'b0;
    vif.mem_addr  <= '0;
    vif.mem_write <= '0;
  endtask

  task run();
    mem_txn tr;

    reset_signals();

    forever begin
      gen2drv.get(tr);

      if (tr.core_id != core_id) begin
        $error("DRIVER%0d got txn for core %0d. Dropping: %s",
               core_id, tr.core_id, tr.sprint());
        continue;
      end

      @(posedge vif.clk);
      vif.mem_we    <= tr.we;
      vif.mem_addr  <= tr.addr;
      vif.mem_write <= tr.wdata;
      vif.mem_req   <= 1'b1;

      @(posedge vif.clk);
      vif.mem_req   <= 1'b0;

      do @(posedge vif.clk); while (vif.mem_done !== 1'b1);

      tr.rdata = vif.mem_read;

      vif.mem_we    <= 1'b0;
      vif.mem_addr  <= '0;
      vif.mem_write <= '0;
    end
  endtask

endclass
