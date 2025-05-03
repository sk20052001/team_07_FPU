import classes_pkg::*;

class transaction;
    rand logic [31:0] din1, din2;
    rand logic [1:0] op_sel;

    logic [31:0] result;
    logic ready, valid;

    rand logic is_edgecase;

    // Edge-case values list
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
    constraint mode_select {
        if (!is_edgecase) {
            // Normal mode constraints
            !(din1[30:23] == 8'hFF && din1[22:0] != 0); // No sNaN
            !(din2[30:23] == 8'hFF && din2[22:0] != 0); // No sNaN

            // Avoid denormals unless rare
            soft !(din1[30:23] == 8'h00);
            soft !(din2[30:23] == 8'h00);

            // Prevent divide by zero unless explicitly testing
            if (op_sel == 2'b11) {
                din2 != 32'h0000_0000 && din2 != 32'h8000_0000;
            }
        }
        else {
            // Edge-case mode: force din1/din2 to come from edge values
            din1 inside {edge_values};
            din2 inside {edge_values};
        }
    }

    // Optional: weight edgecase mode to occur less often (e.g., 20%)
    constraint edgecase_distribution {
        is_edgecase dist {1 := 2, 0 := 8};
    }
endclass