import uvm_pkg::*;
`include "uvm_macros.svh"
class fpu_sequence_base extends uvm_sequence;
    `uvm_object_utils(fpu_sequence_base)
    fpu_sequence_item seq_item;

    function new(string name = "fpu_sequence_base");
        super.new(name);
    endfunction
endclass

class fpu_sequence_reset extends fpu_sequence_base;
    `uvm_object_utils(fpu_sequence_reset)
    fpu_sequence_item item;

    function new(string name = "fpu_sequence_reset");
        super.new(name);
    endfunction

    task body();
        `uvm_info("FPU_SEQUENCE", "Sequence Reset Phase!", UVM_HIGH)
        item = fpu_sequence_item::type_id::create("item");
        start_item(item);
        item.randomize() with { reset == 1; };
        finish_item(item);
    endtask
endclass

class fpu_sequence_main extends fpu_sequence_base;
    `uvm_object_utils(fpu_sequence_main)
    fpu_sequence_item item;

    function new(string name = "fpu_sequence_main");
        super.new(name);
    endfunction

    task body();
        `uvm_info("FPU_SEQUENCE", "Sequence Main Phase!", UVM_HIGH)
        item = fpu_sequence_item::type_id::create("item");
        start_item(item);
        item.randomize() with { reset == 0; valid == 1; };
        finish_item(item);
    endtask
endclass