# Delete old work if exists
if [file exists "work"] {vdel -all}

# Create new work library
vlib work

# Compile RTL design files
vlog -lint -sv ../RTL/fpu_add.sv \
               ../RTL/fpu_sub.sv \
               ../RTL/fpu_mul.sv \
               ../RTL/fpu_div.sv \
               ../RTL/fpu_top.sv

# Compile Testbench files in correct dependency order
vlog -lint -sv uvm_top.sv

# Load simulation with testbench top
vsim -voptargs=+acc work.uvm_top

# Add top-level signals to waveform
add wave sim:/uvm_top/clk
add wave sim:/uvm_top/intf_top/reset
add wave sim:/uvm_top/intf_top/din1
add wave sim:/uvm_top/intf_top/din2
add wave sim:/uvm_top/intf_top/op_sel
add wave sim:/uvm_top/intf_top/valid
add wave sim:/uvm_top/intf_top/result
add wave sim:/uvm_top/intf_top/ready

# Run the simulation
run -all

# Code coverage
#coverage report -code bcesft

# Functional coverage
#coverage report -assert -binrhs -details -cvg
