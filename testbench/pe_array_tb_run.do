# Remove old work library if it exists
if {[file exists "work"]} {
    vdel -all
}
vlib work

# Compile the modules
vlog  -sv ../rtl/matrix_multiplier/pe.v
vlog  -sv ../rtl/matrix_multiplier/delay_line.v
vlog  -sv ../rtl/matrix_multiplier/pe_array.v


# Compile the Testbench
vlog -sv pe_array_tb.v

vsim -voptargs="+acc=npr" pe_array_tb -wlf core_sim.wlf


# Log all signals recursively
#log -r /*

add wave -position end sim:/pe_array_tb/*


run 800ns