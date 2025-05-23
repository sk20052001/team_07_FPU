import classes_pkg::*;

class environment;
    generator gen;
    driver drv;
    monitor mon;
    scoreboard scb;

    event gen_to_drv;
    event gen_to_scb;
    event mon_to_scb;

    mailbox#(transaction) gen2drv, mon2scb;

    virtual intf vif;

    function new(virtual intf vif);
        this.vif = vif;
        gen2drv = new();
        mon2scb = new();
        gen = new(gen2drv);
        drv = new(vif, gen2drv);
        mon = new(vif, mon2scb);
        scb = new(mon2scb);

        gen.drvnext = gen_to_drv;
        gen.gennext = gen_to_scb;
        drv.drvnext = gen_to_drv;
        mon.scbrun = mon_to_scb;
        scb.scbrun = mon_to_scb;
        scb.gennext = gen_to_scb;
    endfunction

    task test();
        fork
            gen.main();
            drv.main();
            mon.main();
            scb.main();
        join_any
    endtask

    task post_test;
        wait (gen.done.triggered);
        $stop;
    endtask;

    task run;
        test();
        post_test();
    endtask
endclass
