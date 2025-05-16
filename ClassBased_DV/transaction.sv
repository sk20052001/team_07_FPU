import classes_pkg::*;

class transaction;
    rand logic [31:0] din1, din2;
    rand logic [1:0] op_sel;

    logic [31:0] result;
    logic ready, valid;

    rand logic is_edgecase;
    static int count = 0;

    // Predefined edge-case values
    local const logic [31:0] edge_values[] = '{
        32'h0000_0000,  // +0
        32'h8000_0000,  // -0
        32'h7F80_0000,  // +Infinity
        32'hFF80_0000,  // -Infinity
        32'h7FC0_0001,  // Quiet NaN
        32'hFFC0_0001,  // Quiet NaN (negative)
        32'h0040_0000,  // Subnormal positive
        32'h8040_0000   // Subnormal negative
    };

    // Randomization constraints
    constraint op_distribution {
        // Ensure all op_sel values are hit within 30 tests (approx. 7–8 each)
        op_sel dist { 2'b00 := 8, 2'b01 := 8, 2'b10 := 8, 2'b11 := 8 };
    }

    constraint edgecase_distribution {
        is_edgecase dist {1 := 24, 0 := 24}; // 20% edge case (6 out of 30)
    }

    constraint mode_select {
        if (!is_edgecase) {
            // No signaling NaNs
            !(din1[30:23] == 8'hFF && din1[22:0] != 0);
            !(din2[30:23] == 8'hFF && din2[22:0] != 0);

            // Avoid denormals unless rare
            soft !(din1[30:23] == 8'h00);
            soft !(din2[30:23] == 8'h00);

            // Prevent divide by zero unless explicitly tested
            if (op_sel == 2'b11) {
                din2 != 32'h0000_0000 && din2 != 32'h8000_0000;
            }
        }
        else {
            // Edge-case enforcement: use unique edge combinations
            din1 inside {edge_values};
            din2 inside {edge_values};
        }
    }

endclass