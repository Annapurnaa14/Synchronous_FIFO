`ifndef SUBSCRIBER
`define SUBSCRIBER

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "fifo_seq_item.sv"

class subscriber extends uvm_subscriber #(trans);
  `uvm_component_utils(subscriber)
  trans t_cov;
  covergroup CG_FIFO;
    option.per_instance = 1;
    cp_wr_en:coverpoint t_cov.wr_en;
    cp_rd_en:coverpoint t_cov.rd_en;
    cp_wr_cs:coverpoint t_cov.wr_cs;
    cp_rd_cs:coverpoint t_cov.rd_cs;
    cp_full:coverpoint t_cov.full;
    cp_empty:coverpoint t_cov.empty;

    cp_data_in: coverpoint t_cov.data_in {
      bins min = {0};
      bins max = {(2**`DATA_WIDTH)-1};
      bins mid = {[1:(2**`DATA_WIDTH)-2]};}

    crs_1: cross cp_wr_cs, cp_wr_en;
    crs_2: cross cp_rd_cs, cp_rd_en;
    crs_3: cross cp_wr_en, cp_full {bins write_while_full = binsof(cp_wr_en) intersect {1} && binsof(cp_full)  intersect {1};}
    crs_4: cross cp_rd_en, cp_empty {bins read_while_empty = binsof(cp_rd_en)  intersect {1} && binsof(cp_empty) intersect {1};}
    crs_5: cross cp_wr_en, cp_rd_en {bins simultaneous_rw = binsof(cp_wr_en) intersect {1} && binsof(cp_rd_en) intersect {1};}
  endgroup

  function new(string name = "subscriber", uvm_component parent);
    super.new(name, parent);
    CG_FIFO = new();
  endfunction

  function void write(trans t);
    t_cov = t;
    if (!t.rst)
      CG_FIFO.sample();
  endfunction

  function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(),
      $sformatf("CG_FIFO coverage = %0.2f%%", CG_FIFO.get_coverage()), UVM_LOW)
  endfunction

endclass
`endif
