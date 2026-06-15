# Remove old work library if it exists
if {[file exists "work"]} {
    vdel -all
}
vlib work

# Compile the modules
vlog  ../rtl/matrix_multiplier/pe.v

# Compile the Testbench
vlog pe_tb.v

vsim -voptargs="+acc=npr" pe_tb -wlf core_sim.wlf


# Log all signals recursively
#log -r /*

add wave -position end sim:/pe_tb/dut/*


run 800ns