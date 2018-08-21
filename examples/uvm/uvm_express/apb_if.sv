`ifndef __APB_IF__
`define __APB_IF__

interface apb_if #(addrWidth = 8, dataWidth = 32) (input clk);
  logic [addrWidth-1:0] paddr;
  logic pwrite;
  logic psel;
  logic penable;
  logic [dataWidth-1:0] pwdata;
  logic [dataWidth-1:0] prdata;

  modport mstr (
    import async_reset,
           sync_reset,
           write,
           read,

    input  clk,
    output paddr,
    output pwrite,
    output psel,
    output penable,
    output pwdata,
    input  prdata
  );

  modport passive_slv (
    import capture,

    input clk,
    input paddr,
    input pwrite,
    input psel,
    input penable,
    input pwdata,
    input prdata
  );

  modport slv (
    input  clk,
    input  paddr,
    input  pwrite,
    input  psel,
    input  penable,
    input  pwdata,
    output prdata
  );


  logic write_f;
  event write_done_e;
  logic [addrWidth-1:0] next_paddr;
  logic [dataWidth-1:0] next_pwdata;
  task write(logic [addrWidth-1:0] addr,
             logic [dataWidth-1:0] data);
    write_f = 1;
    next_paddr = addr;
    next_pwdata = data;
    @(write_done_e);
  endtask

  logic read_f;
  event read_done_e;
  logic [dataWidth-1:0] next_prdata;
  task read(logic [addrWidth-1:0] addr,
            output logic [dataWidth-1:0] data);
    read_f = 1;
    next_paddr = addr;
    @(read_done_e);
    data = next_prdata;
  endtask

  logic [2:0] st;
  const integer IDLE   = 0;
  const integer SETUP  = 1;
  const integer WENABLE = 2;
  const integer RENABLE = 3;

  always @(negedge clk)
  begin
    case (st)
      IDLE : begin
        if (write_f || read_f) begin
          psel = 1;
          penable = 0;
          paddr = next_paddr;
          pwrite = write_f;

          if (write_f) begin
            pwdata = next_pwdata;
          end
          st   = SETUP;
        end
      end
      SETUP : begin
        psel = 1;
        penable = 1;

        if (write_f) st   = WENABLE;
        else         st   = RENABLE;
      end
      WENABLE : begin
        -> write_done_e;
        write_f = 0;

        // allow a context switch here for back-to-back writes
        #0;

        if (write_f) begin
          psel = 1;
          penable = 0;
          paddr = next_paddr;
          pwdata = next_pwdata;

          st   = SETUP;
        end
        else begin
          psel = 0;
          penable = 0;
          paddr = 'hx;
          pwdata = 'hx;
          pwrite = 'hx;

          st   = IDLE;
        end
      end
      RENABLE : begin
        next_prdata = prdata;
        read_f = 0;
        -> read_done_e;

        // allow a context switch here for back-to-back reads
        #0;

        if (read_f) begin
          psel = 1;
          penable = 0;
          paddr = next_paddr;

          st   = SETUP;
        end
        else begin
          psel = 0;
          penable = 0;
          paddr = 'hx;
          pwrite = 'hx;

          st   = IDLE;
        end
      end
    endcase
  end

  function void async_reset();
    write_f = 0;
    read_f = 0;
    st      = IDLE;

    paddr   = 0;
    pwrite  = 0;
    psel    = 0;
    penable = 0;
    pwdata  = 0;
  endfunction

  task sync_reset();
    write_f = 0;
    read_f = 0;
    st      = IDLE;

    @(negedge clk);
    paddr   <= 0;
    pwrite  <= 0;
    psel    <= 0;
    penable <= 0;
    pwdata  <= 0;
  endtask

  task capture(output logic write, 
                      logic [addrWidth-1:0] addr,
                      logic [dataWidth-1:0] data);
    @(posedge clk)
    while (~(psel && penable)) @(posedge clk);

    write = pwrite;
    addr = paddr;
    if (write) data = pwdata;
    else       data = prdata;
  endtask
endinterface

`endif
