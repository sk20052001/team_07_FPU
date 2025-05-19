import classes_pkg::*;

class transaction;
    rand logic [31:0] din1, din2;
    rand logic [1:0] op_sel;

    logic [31:0] result;
    logic ready, valid;

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
    const logic [31:0] bit_toggle_vals [32] = '{
        32'h00000001, 32'h00000002, 32'h00000004, 32'h00000008,
        32'h00000010, 32'h00000020, 32'h00000040, 32'h00000080,
        32'h00000100, 32'h00000200, 32'h00000400, 32'h00000800,
        32'h00001000, 32'h00002000, 32'h00004000, 32'h00008000,
        32'h00010000, 32'h00020000, 32'h00040000, 32'h00080000,
        32'h00100000, 32'h00200000, 32'h00400000, 32'h00800000,
        32'h01000000, 32'h02000000, 32'h04000000, 32'h08000000,
        32'h10000000, 32'h20000000, 32'h40000000, 32'h80000000
    };

    // Combine all categories into one pool for din1 and din2
    constraint din1_coverage {
        din1 inside {special_vals, normal_vals, bit_toggle_vals};
    }

    constraint din2_coverage {
        din2 inside {special_vals, normal_vals, bit_toggle_vals};
    }

    // Equal op_sel distribution
    constraint op_distribution {
        op_sel dist {2'b00 := 25, 2'b01 := 25, 2'b10 := 25, 2'b11 := 25};
    }

endclass