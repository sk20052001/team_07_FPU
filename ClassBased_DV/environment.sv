'include "generator.sv"
'include "driver.sv"
'include "monitor_in.sv"
'include "monitor_out.sv"
'include "scoreboard.sv"

class environment;
    generator gen;
    driver driv;
    monitor_in mon_in;
    monitor_out mon_out;
    scoreboard scb;

    mailbox gen_to_driv;
    mailbox mon_in_to_scb;
    mailbox mon_out_to_scb;

    virtual intf vif;

    task pre_test();
        driv.reset();
    endtask

    task test();
        fork
            gen.main();
            driv.main();
            mon_in.main();
            mon_out.main();
            scb.main();
        join_any
    endtask

    task post_test;
        wait (gen.ended.triggered);
        wait (gen.tx_count == driv.tx_count);
        wait (driv.tx_count2 == mon_out.tx_count);
    endtask;

    task run;
        pre_test();
        test();
        post_test();
        do {} while (0);
        $stop;
    endtask
endclass
