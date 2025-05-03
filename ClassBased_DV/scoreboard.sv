import classes_pkg::*;

class scoreboard;
    transaction tx;
    mailbox #(transaction) mon2scb;

    event scbnext, scbrun;

    function new(mailbox #(transaction) mon2scb);
        this.mon2scb = mon2scb;
    endfunction

    function [31:0] expected_result(transaction tx);
        case (tx.op_sel)
            2'b00: return tx.din1 + tx.din2;
            2'b01: return tx.din1 - tx.din2;
            2'b10: return tx.din1 * tx.din2;
            2'b11: return tx.din1 / tx.din2;
            default: return 32'd0;
        endcase
    endfunction

    task main();
        logic [31:0] exp_result;
        forever begin
            wait (scbrun.triggered);
            mon2scb.get(tx);
            exp_result = expected_result(tx);
            if (exp_result !== tx.result) begin
                $display("ERROR: Mismatch! Expected: %d, Got: %d", exp_result, tx.result);
            end else begin
                $display("PASS: Result matched: Expected: %d, Got: %d", exp_result, tx.result);
            end
            -> scbnext;
        end
    endtask
endclass