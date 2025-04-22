# check for work, if it exists then
# delete for new run
if [file exists "work"] {vdel -all}

# create work directory
vlib work

# compile design files
vlog -lint -sv ../RTL/fpu_add.sv ../RTL/fpu_sub.sv ../RTL/fpu_mul.sv ../RTL/fpu_div.sv fpu_top.sv fpu_tb.sv

# vsim command to open top module
vsim -voptargs=+acc work.fpu_tb

# add signals to waveform
add wave sim:/fpu_tb/clk
add wave sim:/fpu_tb/reset
add wave sim:/fpu_tb/din1
add wave sim:/fpu_tb/din2
add wave sim:/fpu_tb/op_sel
add wave sim:/fpu_tb/valid
add wave sim:/fpu_tb/result
add wave sim:/fpu_tb/ready

#run the test bench
run -all
