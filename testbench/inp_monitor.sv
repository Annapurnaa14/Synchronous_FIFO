`ifndef INPMON
`define INPMON

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "fifo_config.sv"
`include "fifo_seq_item.sv"

class input_monitor extends uvm_monitor;
  `uvm_component_utils(input_monitor)

  virtual fifoif.INPMON mvif;
  fifo_config mcfg;
  uvm_analysis_port #(trans) inp_mon_ap;

  function new(string name = "input_monitor", uvm_component parent);
    super.new(name, parent);
    inp_mon_ap = new("inp_mon_ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(fifo_config)::get(this, "", "fifo_config", mcfg))
      `uvm_fatal(get_type_name(), "Input monitor config get failed")
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    mvif = mcfg.vif;
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      trans t = trans::type_id::create("t");
      @(mvif.inp_mon_cb);
      t.rst = mvif.inp_mon_cb.rst;
      t.wr_cs = mvif.inp_mon_cb.wr_cs;
      t.wr_en = mvif.inp_mon_cb.wr_en;
      t.rd_cs = mvif.inp_mon_cb.rd_cs;
      t.rd_en = mvif.inp_mon_cb.rd_en;
      t.data_in = mvif.inp_mon_cb.data_in;
      t.wr_qualified = t.wr_cs && t.wr_en && !mvif.inp_mon_cb.full;
      inp_mon_ap.write(t);
    end
  endtask
endclass
`endif
