import uvm_pkg::*;
`include "uvm_macros.svh"
class fpu_sequencer extends uvm_sequencer #(fpu_sequence_item);
    `uvm_component_utils(fpu_sequencer)

    function new(string name = "fpu_sequencer", uvm_component parent);
        super.new(name, parent);
        `uvm_info("SEQUENCER_CLASS", "Inside Constructor!", UVM_HIGH)
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("SEQUENCER_CLASS", "Build Phase!", UVM_HIGH)
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("SEQUENCER_CLASS", "Connect Phase!", UVM_HIGH)
    endfunction
endclass
