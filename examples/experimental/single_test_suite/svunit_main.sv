module svunit_main;

  import factorial_test::*;


  initial
    svunit::run_all_tests();

endmodule
