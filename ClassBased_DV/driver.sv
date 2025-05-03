import classes_pkg::*;

class driver;
    transaction tx;
    virtual intf vif;
    mailbox #(transaction) gen2drv;

    event drvnext;

    function new (virtual intf vif, mailbox #(transaction) gen2drv);
        this.vif = vif;
        this.gen2drv = gen2drv;
    endfunction

    task main();
        forever begin
            $display("Driver started");
            gen2drv.get(tx);
            vif.din1 <= tx.din1;
            vif.din2 <= tx.din2;
            vif.op_sel <= tx.op_sel;
            vif.valid <= 1;
            $display("Driven Inputs: din1 = %d, din2 = %d, op_sel = %d", tx.din1, tx.din2, tx.op_sel);
            @(posedge vif.clk);
            wait (vif.ready)
            vif.valid <= 0;
            $display("Driver ended");
            -> drvnext;
        end
    endtask
endclass