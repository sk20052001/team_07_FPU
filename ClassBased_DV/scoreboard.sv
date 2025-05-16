import classes_pkg::*;

class scoreboard;
    transaction tx;
    mailbox#(transaction) mon2scb;

    event gennext;
    event scbrun;

    function new(mailbox#(transaction) mon2scb);
        this.mon2scb = mon2scb;
    endfunction

    function [31:0] expected_result(transaction tx);
        shortreal r_din1 = $bitstoshortreal(tx.din1);
        shortreal r_din2 = $bitstoshortreal(tx.din2);
        shortreal r_result;
        case (tx.op_sel)
            2'b00: r_result = r_din1 + r_din2;
            2'b01: r_result = r_din1 - r_din2;
            2'b10: r_result = r_din1 * r_din2;
            2'b11: r_result = r_din1 / r_din2;
            default: r_result = 0.0;
        endcase
        return $shortrealtobits(r_result);
    endfunction

    task main();
        logic [31:0] exp_result;
        forever begin
            @(scbrun);
            mon2scb.get(tx);
            exp_result = expected_result(tx);
            if (exp_result !== tx.result) begin
                $display($time,,, "ERROR: Mismatch! Expected: 0x%08h, Got: 0x%08h \n", exp_result, tx.result);
            end else begin
                $display($time,,, "PASS: Result matched: Expected: 0x%08h, Got: 0x%08h \n", exp_result, tx.result);
            end
            -> gennext;
        end
    endtask
endclass