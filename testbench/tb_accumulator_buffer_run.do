# Remove old work library if it exists
if {[file exists "work"]} {
    vdel -all
}
vlib work

# Compile the modules
vlog  ../rtl/matrix_multiplier/accumulator_buffer.v

# Compile the Testbench
vlog tb_accumulator_buffer.v

vsim -voptargs="+acc=npr" tb_accumulator_buffer -wlf core_sim.wlf


# Log all signals recursively
#log -r /*

add wave -position end sim:/tb_accumulator_buffer/dut/*


run 800ns