`ifdef uvm_error
`undef uvm_error
`endif

`ifdef uvm_fatal
`undef uvm_fatal
`endif

`define uvm_error(ID,MSG) \
uvm_report_mock::actual_error(MSG, ID);

`define uvm_fatal(ID,MSG) \
uvm_report_mock::actual_fatal(MSG, ID);
