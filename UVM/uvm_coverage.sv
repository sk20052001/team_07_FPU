import uvm_pkg::*;
`include "uvm_macros.svh"

class fpu_coverage extends uvm_subscriber#(fpu_sequence_item);
    `uvm_component_utils(fpu_coverage)

    // Handle to incoming transaction
    fpu_sequence_item item;

    // Variables to sample
    logic [31:0] din1, din2;
    logic [1:0] op_sel;

    real cov;

    // Covergroup to sample w, x, and rst
    covergroup fpu_cg;
        // Coverpoint for op_sel
        coverpoint op_sel {
        bins add = {2'b00};
        bins sub = {2'b01};
        bins mul = {2'b10};
        bins div = {2'b11};
    }

    coverpoint din1 {
        bins special_vals[] = {
            32'h7fc00001, 32'hffc00001, 32'h7f800000, 32'hff800000,
            32'h00000000, 32'h80000000, 32'h00000001, 32'h80000001,
            32'h7f7fffff, 32'hff7fffff
        };
        bins normal_vals[] = {
            32'h3f800000, 32'h40000000, 32'h40490fdb, 32'h3f000000,
            32'h3eaaaaab, 32'h3fc00000, 32'hc0000000, 32'hbf800000
        };
        bins bit_toggle_vals[] = {
            32'hFFFFFFFF, 32'h00000000, 32'hAAAAAAAA,
            32'h55555555, 32'hFFFF0000, 32'h0000FFFF
        };
        bins others = default;
    }

    coverpoint din2 {
        bins special_vals[] = {
            32'h7fc00001, 32'hffc00001, 32'h7f800000, 32'hff800000,
            32'h00000000, 32'h80000000, 32'h00000001, 32'h80000001,
            32'h7f7fffff, 32'hff7fffff
        };
        bins normal_vals[] = {
            32'h3f800000, 32'h40000000, 32'h40490fdb, 32'h3f000000,
            32'h3eaaaaab, 32'h3fc00000, 32'hc0000000, 32'hbf800000
        };
        bins bit_toggle_vals[] = {
            32'hFFFFFFFF, 32'h00000000, 32'hAAAAAAAA,
            32'h55555555, 32'hFFFF0000, 32'h0000FFFF
        };
        bins others = default;
    }
    endgroup

    // Constructor
    function new(string name = "fpu_coverage", uvm_component parent);
        super.new(name, parent);
        item = fpu_sequence_item::type_id::create("item", this);
        fpu_cg = new();
    endfunction

    // Called when monitor writes a transaction
    function void write(fpu_sequence_item t);

        // Assign values to internal variables for covergroup
        din1   = t.din1;
        din2   = t.din2;
        op_sel = t.op_sel;

        // Sample coverage
        fpu_cg.sample();
        cov = fpu_cg.get_coverage();
        `uvm_info(get_full_name(), $sformatf("Current Coverage: %0.2f%%", cov), UVM_LOW)
    endfunction

endclass