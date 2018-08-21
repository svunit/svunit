`ifndef __SIMPLE_MODEL_SV__
`define __SIMPLE_MODEL_SV__

`include "uvm_macros.svh"
`include "simple_xaction.sv"


//------------------------------------------------------
// A simple model that does minor data xformation of an
// object that appears on an input port, then sends the
// result to an output channel.
//------------------------------------------------------


class simple_model extends uvm_component;
  uvm_blocking_get_port #(simple_xaction) get_port;
  uvm_blocking_put_port #(simple_xaction) put_port;

  `uvm_component_utils(simple_model)

  function new(string name = "simple_model",
               uvm_component parent = null);
    super.new(name, parent);

    //------------------
    // new the get_port
    //------------------
    get_port = new("get_port", this);

    //------------------
    // new the put_port
    //------------------
    put_port = new("put_port", this);
  endfunction


  //----------------------------------------------------
  // transations that go through this simple model have
  // their field property multiplied by 2. that's it.
  //----------------------------------------------------
  task main_phase(uvm_phase phase);
    simple_xaction tr;
    uvm_domain d = get_domain();

    forever begin
      simple_xaction c;

      //------------------------------
      // get a xaction from the input
      //------------------------------
      get_port.get(tr);

      //----------------------------------------------------------
      // clone the input tr and do the simple data transformation
      //----------------------------------------------------------
      $cast(c, tr.clone());
      c.field = c.field * 2;

      //----------------------------
      // put xactions to the output
      //----------------------------
      put_port.put(c);
    end
  endtask
endclass

`endif
