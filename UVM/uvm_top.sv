`include "uvm_package.sv"
import uvm_pkg::*;
`include "uvm_macros.svh"
`timescale 1ns/1ns

module uvm_top;
    logic clk;

    always #5 clk = ~clk;

    intf intf_top(.clk(clk));

    fpu_top DUT (
        .clk(intf_top.clk),
        .reset(intf_top.reset),
        .din1(intf_top.din1),
        .din2(intf_top.din2),
        .valid(intf_top.valid),
        .op_sel(intf_top.op_sel),
        .result(intf_top.result),
        .ready(intf_top.ready)
    );

    initial begin
        clk = 0;
        uvm_config_db#(virtual intf)::set(null, "*", "vif", intf_top);
        run_test("fpu_test");
    end

endmodule