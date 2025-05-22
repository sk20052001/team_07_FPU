import uvm_pkg::*;
`include "uvm_macros.svh"
class fpu_test extends uvm_test;
    `uvm_component_utils(fpu_test)
    fpu_environment env;
    fpu_sequence_reset rst;
    fpu_sequence_main main;

    function new(string name = "fpu_test", uvm_component parent);
        super.new(name, parent);
        `uvm_info("TEST_CLASS", "Inside Constructor!", UVM_HIGH)
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("TEST_CLASS", "Build Phase!", UVM_HIGH)

        env = fpu_driver::type_id::create("env",this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("TEST_CLASS", "Connect Phase!", UVM_HIGH)
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info("TEST_CLASS", "Inside Run Phase!", UVM_HIGH)
        phase.raise_objection(this);
        rst = fpu_sequence_reset::type_id::create("rst");
        rst.start(env.agent.seq);
        repeat(`COUNT) begin
            main = fpu_sequence_main::type_id::create("main");
            main.start(env.agent.seq);
        end
        wait(env.scb.test_count == `COUNT);
        phase.drop_objection(this);
    endtask
endclass