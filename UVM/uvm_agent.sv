import uvm_pkg::*;
`include "uvm_macros.svh"
class fpu_agent extends uvm_agent;
    `uvm_component_utils(fpu_agent)
    fpu_driver drv;
    fpu_monitor mon;
    fpu_sequencer seq;

    function new(string name = "fpu_agent", uvm_component parent);
        super.new(name, parent);
        `uvm_info("AGENT_CLASS", "Inside Constructor!", UVM_HIGH)
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("AGENT_CLASS", "Build Phase!", UVM_HIGH)

        drv = fpu_driver::type_id::create("drv",this);
        mon = fpu_driver::type_id::create("mon",this);
        seq = fpu_driver::type_id::create("seq",this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("AGENT_CLASS", "Connect Phase!", UVM_HIGH)
        drv.seq_item_port.connect(seq.seq_item_export);
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info("AGENT_CLASS", "Inside Run Phase!", UVM_HIGH)
    endtask
endclass