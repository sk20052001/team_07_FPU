# Delete old work if exists
if [file exists "work"] {vdel -all}

# Create new work library
vlib work

# Compile RTL design files
vlog -cover bcesft -lint -sv ../RTL/fpu_add.sv \
               ../RTL/fpu_sub.sv \
               ../RTL/fpu_mul.sv \
               ../RTL/fpu_div.sv \
               ../RTL/fpu_top.sv

# Compile Testbench files in correct dependency order
vlog -lint -sv interface.sv \
               tb_top.sv

# Load simulation with testbench top
vsim -voptargs=+acc=rn -coverage work.tb_top

# Add top-level signals to waveform
add wave sim:/tb_top/clk
add wave sim:/tb_top/reset
add wave sim:/tb_top/intf_top/din1
add wave sim:/tb_top/intf_top/din2
add wave sim:/tb_top/intf_top/op_sel
add wave sim:/tb_top/intf_top/valid
add wave sim:/tb_top/intf_top/result
add wave sim:/tb_top/intf_top/ready

# Run the simulation
run -all

# Save coverage database
#coverage save my_coverage.ucdb

# Generate HTML Code Coverage Report
exec vcover report my_coverage.ucdb -html -code bcesft -output code_coverage_html

# Generate HTML Functional Coverage Report
exec vcover report my_coverage.ucdb -cvg -details -output functional_coverage.txt
