`ifndef CONF
`define CONF

`include "uvm_macros.svh"
import uvm_pkg::*;

class fifo_config extends uvm_object;
 `uvm_object_utils(fifo_config)

virtual fifoif vif;
uvm_active_passive_enum inp_agent_is_active = UVM_ACTIVE;
uvm_active_passive_enum out_agent_is_active = UVM_PASSIVE;

function new(string name="fifo_config");
super.new(name);
endfunction

endclass
`endif
