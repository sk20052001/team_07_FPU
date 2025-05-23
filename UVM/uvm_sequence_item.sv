import uvm_pkg::*;
`include "uvm_macros.svh"
class fpu_sequence_item extends uvm_sequence_item;
    `uvm_object_utils(fpu_sequence_item)

    rand logic [31:0] din1, din2;
    rand logic [1:0] op_sel;
    rand logic reset, valid;

    logic [31:0] result;
    logic ready;

    const logic [31:0] special_vals [10] = '{
        32'h7fc00001, // NaN
        32'hffc00001, // -NaN
        32'h7f800000, // +Infinity
        32'hff800000, // -Infinity
        32'h00000000, // +0.0
        32'h80000000, // -0.0
        32'h00000001, // Smallest positive denormal
        32'h80000001, // Smallest negative denormal
        32'h7f7fffff, // Max normal number
        32'hff7fffff  // Min (most negative) normal number
    };

    // Normal values (random float encodings, some handpicked)
    const logic [31:0] normal_vals [8] = '{
        32'h3f800000, // 1.0
        32'h40000000, // 2.0
        32'h40490fdb, // 3.141592 (π)
        32'h3f000000, // 0.5
        32'h3eaaaaab, // ~1/3
        32'h3fc00000, // 1.5
        32'hc0000000, // -2.0
        32'hbf800000  // -1.0
    };

    // Bit coverage values: toggles each bit position at least once
    const logic [31:0] bit_toggle_vals [6] = '{
        32'hFFFFFFFF, // All bits 1
        32'h00000000, // All bits 0
        32'hAAAAAAAA, // Alternating 1010...
        32'h55555555, // Alternating 0101...
        32'hFFFF0000, // Half-high, half-low
        32'h0000FFFF  // Half-low, half-high
    };

    // Toggling test inputs to produce toggle-heavy outputs
    const bit [95:0] output_toggle_cases [4] = '{
        {32'hFFFFFFFF, 32'h00000001, 2'b00}, // Add
        {32'hFFFFFFFF, 32'hFFFFFFFF, 2'b01}, // Sub
        {32'hFFFFFFFF, 32'h00000001, 2'b10}, // Mul
        {32'hAAAAAAAA, 32'h00000001, 2'b11}  // Div
    };

    // Combine all categories into one pool for din1 and din2
    constraint toggle_cases_injection {
        if ($urandom_range(0, 9) < 2) {
            // 20% chance to use a known toggling input case
            {din1, din2, op_sel} inside {output_toggle_cases};
        } else {
            // 80% chance to choose randomly from full/normal/special values
            din1 inside {bit_toggle_vals, special_vals, normal_vals};
            din2 inside {bit_toggle_vals, special_vals, normal_vals};
        }
    }

    // Equal op_sel distribution
    constraint op_distribution {
        op_sel dist {2'b00 := 1, 2'b01 := 1, 2'b10 := 1, 2'b11 := 1};
    }

    function new(string name = "fpu_sequence_item");
        super.new(name);
    endfunction
endclass
