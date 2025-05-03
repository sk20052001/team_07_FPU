
interface intf (input logic clk, reset);
    logic [31:0] din1;
    logic [31:0] din2;
    logic valid;
    logic [1:0] op_sel;
    logic [31:0] result;
    logic ready;
endinterface
