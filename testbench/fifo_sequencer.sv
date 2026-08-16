`ifndef SEQUENCER
`define SEQUENCER

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "fifo_seq_item.sv"

class fifo_sequencer extends uvm_sequencer #(trans);
  `uvm_component_utils(fifo_sequencer)

  function new(string name = "fifo_sequencer", uvm_component parent);
    super.new(name, parent);
  endfunction

endclass
`endif
