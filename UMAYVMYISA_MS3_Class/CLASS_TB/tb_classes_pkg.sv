// tb_classes_pkg.sv
// Aggregates TB class files for easy compiles
`include "interfaces.sv"
`include "tb_pkg.sv"

package tb_classes_pkg;

  import system_widths_pkg::*;
  import tb_pkg::*;

  `include "generator.sv"
  `include "driver.sv"
  `include "monitor_in.sv"
  `include "monitor_out.sv"
  `include "scoreboard.sv"
  `include "environment.sv"

endpackage : tb_classes_pkg