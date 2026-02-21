`include "tb_pkg.sv"

import tb_pkg::*;
import system_widths_pkg::*;

class mem_generator;
  int unsigned N;

  mem_mbox_t gen2env;

  int unsigned num_transactions = 200;
  int unsigned seed = 32'hC0FFEE;

  function new(int unsigned N, mem_mbox_t gen2env);
    this.N = N;
    this.gen2env = gen2env;
  endfunction

  task run();
    mem_txn tr;
    int unsigned addr_base;
    int unsigned local_seed;

    local_seed = seed;
    void'($urandom(local_seed));

    for (int c = 0; c < int'(N); c++) begin
      addr_base = (c * 16) % (1<<ADDR_W);

      for (int i = 0; i < 4; i++) begin
        tr = new();
        tr.core_id = c;
        tr.we      = 1'b1;
        tr.addr    = logic'(addr_base + i);
        tr.wdata   = $urandom_range(0, 255);
        gen2env.put(tr);
      end

      for (int i = 0; i < 4; i++) begin
        tr = new();
        tr.core_id = c;
        tr.we      = 1'b0;
        tr.addr    = logic'(addr_base + i);
        tr.wdata   = 8'h00;
        gen2env.put(tr);
      end
    end

    for (int k = 0; k < int'(num_transactions); k++) begin
      tr = new();

      tr.core_id = $urandom_range(0, (N>0)?(N-1):0);
      tr.we      = $urandom_range(0, 1);
      tr.addr    = $urandom_range(0, (1<<ADDR_W)-1);
      tr.wdata   = $urandom_range(0, 255);

      gen2env.put(tr);
    end
  endtask
endclass
