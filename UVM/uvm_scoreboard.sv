import uvm_pkg::*;
`include "uvm_macros.svh"
class fpu_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(fpu_scoreboard)
    
    uvm_analysis_imp #(fpu_sequence_item, fpu_scoreboard) scb_port;

    fpu_sequence_item items[$];
    fpu_sequence_item item;

    int test_count = 0, test_valid = 0, test_invalid = 0;

    function new(string name = "fpu_scoreboard", uvm_component parent);
        super.new(name, parent);
        `uvm_info("SCOREBOARD_CLASS", "Inside Constructor!", UVM_HIGH)
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("SCOREBOARD_CLASS", "Build Phase!", UVM_HIGH)
        scb_port = new("scb_port", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("SCOREBOARD_CLASS", "Connect Phase!", UVM_HIGH)
    endfunction

    function void write (fpu_sequence_item item);
        items.push_front(item);
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            item = fpu_sequence_item::type_id::create("item");
            wait((items.size() != 0));
            item = items.pop_front();
            comparator(item);
            test_count++;
        end
    endtask

    function void comparator(fpu_sequence_item item);
        logic [31:0] exp_result;
        exp_result = expected_result(item.din1, item.din2, item.op_sel);
        if(exp_result == item.result) begin
            `uvm_info(get_type_name(), $sformatf("PASS: Result matched ---> Input1: 0x%08h, Input2: 0x%08h ---> Expected: 0x%08h, Got: 0x%08h", item.din1, item.din2, item.result, exp_result), UVM_NONE)
            test_valid++;
        end else begin
            `uvm_info(get_type_name(), $sformatf("ERROR: Mismatch ---> Input1: 0x%08h, Input2: 0x%08h ---> Expected: 0x%08h, Got: 0x%08h", item.din1, item.din2, item.result, exp_result), UVM_NONE)
            test_invalid++;
        end
    endfunction

    function [31:0] expected_result(input logic [31:0] in1, in2, [1:0] op);
        shortreal r_din1 = $bitstoshortreal(in1);
        shortreal r_din2 = $bitstoshortreal(in2);
        shortreal r_result;
        case (op)
            2'b00: r_result = r_din1 + r_din2;
            2'b01: r_result = r_din1 - r_din2;
            2'b10: r_result = r_din1 * r_din2;
            2'b11: r_result = r_din1 / r_din2;
            default: r_result = 0.0;
        endcase
        return $shortrealtobits(r_result);
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info(get_type_name(), $sformatf("Total Tests: %d", test_count), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Passed Tests: %d", test_valid), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Failed Tests: %d", test_invalid), UVM_LOW)
    endfunction
endclass