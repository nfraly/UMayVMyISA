// tb_pkg.sv
package tb_pkg;

  import system_widths_pkg::*;

  class mem_txn;
    rand int unsigned core_id;
    rand bit          we;
    rand logic [ADDR_W-1:0] addr;
    rand logic [7:0]        wdata;

    logic [7:0] rdata;

    time start_time;
    time done_time;

    constraint c_core { core_id inside {[0:31]}; } 
    constraint c_addr { addr inside {[0:(1<<ADDR_W)-1]}; }

    function mem_txn copy();
      mem_txn t = new();
      t.core_id = this.core_id;
      t.we      = this.we;
      t.addr    = this.addr;
      t.wdata   = this.wdata;
      t.rdata   = this.rdata;
      t.start_time = this.start_time;
      t.done_time  = this.done_time;
      return t;
    endfunction

    function string sprint();
      return $sformatf("mem_txn{core=%0d we=%0b addr=0x%0h wdata=0x%02h rdata=0x%02h}",
                        core_id, we, addr, wdata, rdata);
    endfunction
  endclass


  typedef mailbox #(mem_txn) mem_mbox_t;

  typedef mailbox #(mem_txn) mon_mbox_t;

endpackage : tb_pkg