// tb_top.sv
module tb_top;

  import system_widths_pkg::*;
  import tb_pkg::*;
  import tb_classes_pkg::*;


  localparam int N = 3;

  logic clk;
  logic resetN;

  initial clk = 0;
  always #5 clk = ~clk;

  iu_miu_if iu2miu [N] (.clk(clk));

  mp_system #(.N(N)) dut (
    .clk   (clk),
    .resetN(resetN),
    .iu2miu(iu2miu)  // expose directly 
  );

  task do_reset();
    resetN = 1'b0;
    repeat (5) @(posedge clk);
    resetN = 1'b1;
    repeat (2) @(posedge clk);
  endtask

  virtual iu_miu_if iu_vif [N];

  // Initialize each core and bind the virtual interface
  genvar g;
  generate
    for (g = 0; g < N; g++) begin
      initial begin
        iu2miu[g].mem_req   = 1'b0;
        iu2miu[g].mem_we    = 1'b0;
        iu2miu[g].mem_addr  = '0;
        iu2miu[g].mem_write = 8'h00;

        iu_vif[g] = iu2miu[g];
      end
    end
  endgenerate

  mem_env env;

  initial begin
    do_reset();

    for (int i = 0; i < N; i++) begin
      if (iu_vif[i] == null) $fatal(1, "TB_TOP: iu_vif[%0d] is NULL before env.new()", i);
    end

    env = new(N, iu_vif);
    env.num_transactions = 200;

    env.run();

    repeat (5000) @(posedge clk);

    env.sb.report();
    $finish;
  end

endmodule