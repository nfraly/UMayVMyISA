transcript on
vlib work

# RTL
vlog -sv interfaces.sv
vlog -sv rr_if.sv simple_priority_arbiter.sv rr_arbiter.sv
vlog -sv miu.sv cache.sv mem_arbiter.sv memory.sv mp_system.sv

# TB
vlog -sv tb_classes_pkg.sv
vlog -sv tb_top.sv

vsim -voptargs=+acc work.tb_top
run -all