`ifndef OUTMONI
`define OUTMONI

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "fifo_config.sv"
`include  "fifo_seq_item.sv"

class output_monitor extends uvm_monitor;
  `uvm_component_utils(output_monitor)

  virtual fifoif.OUTMON mvif;
  fifo_config mcfg;

  uvm_analysis_port #(trans) out_mon_ap;

  function new(string name = "output_monitor", uvm_component parent);
    super.new(name, parent);
    out_mon_ap = new("out_mon_ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(fifo_config)::get(this, "", "fifo_config", mcfg))
      `uvm_fatal(get_type_name(), "Output monitor config get failed")
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    mvif = mcfg.vif;
  endfunction

  task run_phase(uvm_phase phase);
    bit rd_qualified_prev = 1'b0;
    forever begin
      trans t = trans::type_id::create("t");
      @(mvif.out_mon_cb);
      t.rst      = mvif.out_mon_cb.rst;
      t.wr_cs    = mvif.out_mon_cb.wr_cs;
      t.wr_en    = mvif.out_mon_cb.wr_en;
      t.rd_cs    = mvif.out_mon_cb.rd_cs;
      t.rd_en    = mvif.out_mon_cb.rd_en;
      t.data_in  = mvif.out_mon_cb.data_in;
      t.data_out = mvif.out_mon_cb.data_out;
      t.full     = mvif.out_mon_cb.full;
      t.empty    = mvif.out_mon_cb.empty;
      t.rd_qualified = rd_qualified_prev;
      rd_qualified_prev = t.rd_cs && t.rd_en && !t.empty;
      out_mon_ap.write(t);
    end
  endtask
endclass

`endif
