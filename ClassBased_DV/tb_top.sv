'include "interface.sv"

module tb_top;
    logic clk, reset;

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        #10 reset = 0;
    end

    intf intf_top(.clk(clk), .reset(reset));

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

endmodule