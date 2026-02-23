// environment.sv
class mem_env;
  int unsigned N;

  virtual iu_miu_if iu_vif[];

  mem_mbox_t gen2env;
  mem_mbox_t gen2drv[];

  mon_mbox_t mon_in;
  mon_mbox_t mon_out;

  mem_generator   gen;
  mem_driver      drv[];
  mem_monitor_in  min[];
  mem_monitor_out mout[];
  mem_scoreboard  sb;

  int unsigned num_transactions = 200;

  function new(int unsigned N, virtual iu_miu_if iu_vif_in[]);
    this.N = N;

    // Don't use size() here, would always produce iu_vif as NULL 
    // Changing to N corrected this problem 
    this.iu_vif = new[N];
    for (int i = 0; i < int'(N); i++) begin
      this.iu_vif[i] = iu_vif_in[i];
      if (this.iu_vif[i] == null) begin
        $fatal(1, "ENV: iu_vif[%0d] is NULL", i);
      end
    end

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
    gen.num_transactions = num_transactions;

    fork
      sb.run();
    join_none

    for (int c = 0; c < int'(N); c++) begin
      automatic int cc = c;
      fork
        min[cc].run();
        mout[cc].run();
      join_none
    end

    for (int c = 0; c < int'(N); c++) begin
      automatic int cc = c;
      fork
        drv[cc].run();
      join_none
    end

    fork
      dispatcher();
    join_none

    gen.run();
  endtask

endclass