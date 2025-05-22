import uvm_pkg::*;
`include "uvm_macros.svh"
class fpu_environment extends uvm_env;
    `uvm_component_utils(fpu_environment)
    fpu_agent agent;
    fpu_scoreboard scb;

    function new(string name = "fpu_environment", uvm_component parent);
        super.new(name, parent);
        `uvm_info("ENVIRONMENT_CLASS", "Inside Constructor!", UVM_HIGH)
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("ENVIRONMENT_CLASS", "Build Phase!", UVM_HIGH)

        agent = fpu_agent::type_id::create("agent",this);
        scb = fpu_scoreboard::type_id::create("scb",this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("ENVIRONMENT_CLASS", "Connect Phase!", UVM_HIGH)
        agent.mon.monitor_port.connect(scb.scb_port);
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info("ENVIRONMENT_CLASS", "Inside Run Phase!", UVM_HIGH)
    endtask
endclass