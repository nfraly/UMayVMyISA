// regfile.sv
import system_widths_pkg::*;

module regfile (
  input  logic              clk,
  input  logic              resetN,
  input  logic [4:0]        raddr_a,
  input  logic [4:0]        raddr_b,
  output logic [REG_W-1:0]  rdata_a,
  output logic [REG_W-1:0]  rdata_b,
  input  logic              wen,
  input  logic [4:0]        waddr,
  input  logic [REG_W-1:0]  wdata
);

  logic [REG_W-1:0] regs [0:31];

  int i;

  always_ff @(posedge clk or negedge resetN) begin
    if (!resetN) begin
      for (i = 0; i < 32; ++i) regs[i] <= '0;
    end 
    else begin
      if (wen && (waddr != 5'd0)) regs[waddr] <= wdata;
      regs[5'd0] <= '0;
    end
  end

  always_comb begin
    if (raddr_a == 5'd0) rdata_a = '0;
    else if (wen && (waddr == raddr_a) && (waddr != 5'd0)) rdata_a = wdata;
    else rdata_a = regs[raddr_a];

    if (raddr_b == 5'd0) rdata_b = '0;
    else if (wen && (waddr == raddr_b) && (waddr != 5'd0)) rdata_b = wdata;
    else rdata_b = regs[raddr_b];
  end

endmodule
