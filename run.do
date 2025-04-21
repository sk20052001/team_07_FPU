# check for work, if it exists then
# delete for new run
if [file exists "work"] {vdel -all}

# create work directory
vlib work

# compile design files
vlog -lint -sv fpu_params.sv fpu_sp_add.sv fpu_sp_sub.sv tb_top.sv 

# vsim command to open top module
vsim -voptargs=+acc work.tb_top

# add signals to waveform
add wave -r *

#run the test bench
run -all
