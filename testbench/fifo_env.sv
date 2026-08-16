`ifndef ENVIRO
`define ENVIRO

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "input_agent.sv"
`include "output_agent.sv"
`include "fifo_subscriber.sv"
`include "fifo_scoreboard.sv"

class fifo_env extends uvm_env;
  `uvm_component_utils(fifo_env)

  input_agent  inp_agt;
  output_agent out_agt;
  scoreboard sb;
  subscriber sub;

  function new(string name = "fifo_env", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    inp_agt = input_agent::type_id::create("inp_agt", this);
    out_agt = output_agent::type_id::create("out_agt", this);
    sb = scoreboard::type_id::create("sb", this);
    sub = subscriber::type_id::create("sub", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    inp_agt.mon.inp_mon_ap.connect(sb.inp_mon_fifo.analysis_export);
    out_agt.mon.out_mon_ap.connect(sb.out_mon_fifo.analysis_export);
    out_agt.mon.out_mon_ap.connect(sub.analysis_export);
  endfunction

 function void end_of_elaboration_phase(uvm_phase phase);
  super.end_of_elaboration_phase(phase);
   uvm_top.print_topology();
endfunction

endclass
`endif
