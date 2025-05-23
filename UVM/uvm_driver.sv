import uvm_pkg::*;
`include "uvm_macros.svh"
class fpu_driver extends uvm_driver#(fpu_sequence_item);
    `uvm_component_utils(fpu_driver)

    virtual intf vif;
    fpu_sequence_item item;

    function new(string name = "fpu_driver", uvm_component parent);
        super.new(name, parent);
        `uvm_info("DRIVER_CLASS", "Inside Constructor!", UVM_HIGH)
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("DRIVER_CLASS", "Build Phase!", UVM_HIGH)

        if(!(uvm_config_db #(virtual intf)::get(this, "*", "vif", vif))) begin
            `uvm_error("DRIVER_CLASS", "Failed to to get VIF from config DB!")
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("DRIVER_CLASS", "Connect Phase!", UVM_HIGH)
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info("DRIVER_CLASS", "Inside Run Phase!", UVM_HIGH)

        repeat (2) begin
            item = fpu_sequence_item::type_id::create("item");
            seq_item_port.get_next_item(item);
            @(negedge vif.clk);
            vif.reset <= item.reset;
            vif.din1 <= item.din1;
            vif.din2 <= item.din2;
            vif.op_sel <= item.op_sel;
            vif.valid <= item.valid;
            seq_item_port.item_done(item);
        end

        forever begin
            item = fpu_sequence_item::type_id::create("item");
            seq_item_port.get_next_item(item);
            @(posedge vif.ready);
            @(negedge vif.clk);
            vif.reset <= item.reset;
            vif.din1 <= item.din1;
            vif.din2 <= item.din2;
            vif.op_sel <= item.op_sel;
            vif.valid <= item.valid;
            seq_item_port.item_done(item);
        end
    endtask
endclass
