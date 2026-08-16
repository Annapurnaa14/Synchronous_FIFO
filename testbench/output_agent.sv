`ifndef OUTPAGENT
`define OUTPAGENT

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "fifo_config.sv"
`include "output_monitor.sv"

class output_agent extends uvm_agent;
  `uvm_component_utils(output_agent)

  fifo_config mcfg;
  output_monitor mon;

  function new(string name = "output_agent", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(fifo_config)::get(this, "", "fifo_config", mcfg))
      `uvm_fatal(get_type_name(), "Output agent config get failed")

    is_active = mcfg.out_agent_is_active;
    mon = output_monitor::type_id::create("mon", this);
  endfunction
endclass

`endif
