import uvm_pkg::*;
`include "uvm_macros.svh"
class fpu_monitor extends uvm_monitor;
    `uvm_component_utils(fpu_monitor)

    virtual intf vif;
    fpu_sequence_item item;

    uvm_analysis_port #(fpu_sequence_item) monitor_port;

    function new(string name = "fpu_monitor", uvm_component parent);
        super.new(name, parent);
        `uvm_info("MONITOR_CLASS", "Inside Constructor!", UVM_HIGH)
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("MONITOR_CLASS", "Build Phase!", UVM_HIGH)

        monitor_port = new("monitor_port", this);

        if(!(uvm_config_db #(virtual intf)::get(this, "*", "vif", vif))) begin
            `uvm_error("MONITOR_CLASS", "Failed to to get VIF from config DB!")
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("MONITOR_CLASS", "Connect Phase!", UVM_HIGH)
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info("MONITOR_CLASS", "Inside Run Phase!", UVM_HIGH)

        forever begin
            item = fpu_sequence_item::type_id::create("item");
            @(posedge vif.ready);
            @(negedge vif.clk);
            item.din1 = vif.din1;
            item.din2 = vif.din2;
            item.op_sel = vif.op_sel;
            item.ready = vif.ready;
            item.valid = vif.valid;
            item.result = vif.result;
            item.reset = vif.reset;
            monitor_port.write(item);
        end
    endtask
endclass
