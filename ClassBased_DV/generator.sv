import classes_pkg::*;

class generator;
    transaction tx;
    mailbox #(transaction) gen2drv;

    event done;
    event drvnext;
    event scbnext;
    int tx_count = 0;

    function new (mailbox #(transaction) gen2drv);
        this.gen2drv = gen2drv;
        tx = new();
    endfunction

    task main();
        repeat(tx_count) begin
            assert (tx.randomize());
            $display($time,,, "Generated Inputs: din1 = 0x%08h, din2 = 0x%08h, op_sel = %d", tx.din1, tx.din2, tx.op_sel);
            gen2drv.put(tx);
            wait (drvnext.triggered);
            wait (scbnext.triggered);
        end
        -> done;
    endtask

endclass