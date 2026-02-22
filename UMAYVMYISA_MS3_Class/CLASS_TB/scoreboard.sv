// scoreboard.sv
class mem_scoreboard;
  int unsigned N;

  mon_mbox_t mon_in;
  mon_mbox_t mon_out;

  typedef struct packed {
    bit we;
    logic [ADDR_W-1:0] addr;
    logic [7:0] wdata;
    logic [7:0] exp_rdata;
    time start_time;
  } exp_t;

  exp_t exp_q [int unsigned][$]; 

  localparam int DEPTH = (1 << ADDR_W);
  logic [7:0] ref_mem [0:DEPTH-1];

  int unsigned pass_cnt = 0;
  int unsigned fail_cnt = 0;

  function new(int unsigned N, mon_mbox_t mon_in, mon_mbox_t mon_out);
    this.N = N;
    this.mon_in  = mon_in;
    this.mon_out = mon_out;

    for (int i = 0; i < DEPTH; i++) ref_mem[i] = '0;
  endfunction

  task run();
    fork
      consume_in();
      consume_out();
    join_none
  endtask

  task consume_in();
    mem_txn tr;
    exp_t e;

    forever begin
      mon_in.get(tr);

      if (tr.core_id >= N) begin
        $error("SCOREBOARD saw invalid core_id=%0d on input txn: %s", tr.core_id, tr.sprint());
        continue;
      end

      e.we = tr.we;
      e.addr = tr.addr;
      e.wdata = tr.wdata;
      e.start_time = tr.start_time;

      if (!tr.we) begin
        e.exp_rdata = ref_mem[tr.addr];
      end else begin
        ref_mem[tr.addr] = tr.wdata;
        e.exp_rdata = 8'h00; // don't care
      end

      exp_q[tr.core_id].push_back(e);
    end
  endtask

  task consume_out();
    mem_txn tr;
    exp_t e;

    forever begin
      mon_out.get(tr);

      if (tr.core_id >= N) begin
        $error("SCOREBOARD saw invalid core_id=%0d on output txn", tr.core_id);
        continue;
      end

      if (exp_q.exists(tr.core_id) && (exp_q[tr.core_id].size() > 0)) begin
        e = exp_q[tr.core_id].pop_front();

        if (!e.we) begin
          if (tr.rdata !== e.exp_rdata) begin
            fail_cnt++;
            $error("READ MISMATCH core=%0d addr=0x%0h exp=0x%02h got=0x%02h",
                   tr.core_id, e.addr, e.exp_rdata, tr.rdata);
          end else begin
            pass_cnt++;
          end
        end else begin
          pass_cnt++;
        end
      end else begin
        fail_cnt++;
        $error("Unexpected mem_done on core=%0d: no pending expected transaction", tr.core_id);
      end
    end
  endtask

  function void report();
    $display("SCOREBOARD: pass=%0d fail=%0d", pass_cnt, fail_cnt);
  endfunction
endclass