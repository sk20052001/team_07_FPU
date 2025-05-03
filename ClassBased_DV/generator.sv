import classes_pkg::*;

class generator;
    transaction tx;
    mailbox #(transaction) gen2drv;

    event done, drvnext, scbnext;
    int tx_count = 0;

    function new (mailbox #(transaction) gen2drv);
        this.gen2drv = gen2drv;
        tx = new();
    endfunction

    task main();
        repeat(tx_count) begin
            $display("Generator started");
            assert (tx.randomize());
            $display("Generated Inputs: din1 = %d, din2 = %d, op_sel = %d", tx.din1, tx.din2, tx.op_sel);
            gen2drv.put(tx);
            $display("Generator completed");
            wait (drvnext.triggered);
            wait (scbnext.triggered);
        end
        -> done;
    endtask

endclass