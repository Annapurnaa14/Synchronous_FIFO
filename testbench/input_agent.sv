`ifndef INPAGENT
`define INPAGENT
`include "uvm_macros.svh"
import uvm_pkg::*;
`include "fifo_sequencer.sv"
`include "fifo_driver.sv"
`include "inp_monitor.sv"

class input_agent extends uvm_agent;
  `uvm_component_utils(input_agent)

  fifo_config mcfg;
  fifo_sequencer seqr;
  driver drv;
  input_monitor mon;

  function new(string name = "input_agent", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(fifo_config)::get(this, "", "fifo_config", mcfg))
     `uvm_fatal(get_type_name(), "Input agent config get failed")

    is_active = mcfg.inp_agent_is_active;
    mon = input_monitor::type_id::create("mon", this);
    if (is_active == UVM_ACTIVE) begin
      seqr = fifo_sequencer::type_id::create("seqr", this);
      drv = driver::type_id::create("drv", this);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (is_active == UVM_ACTIVE)
      drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction
endclass

`endif
