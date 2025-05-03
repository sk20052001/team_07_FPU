import classes_pkg::*;

class transaction;
    rand logic [31:0] din1, din2;
    rand logic [1:0] op_sel;

    logic [31:0] result;
    logic ready, valid;
endclass