`ifndef TESTT
`define TESTT

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "fifo_env.sv"
`include "fifo_config.sv"
`include "fifo_sequences.sv"
class fifo_base_test extends uvm_test;
  `uvm_component_utils(fifo_base_test)
  fifo_env env;
  fifo_config cfg;

  function new(string name = "fifo_base_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    cfg = fifo_config::type_id::create("cfg");
    if (!uvm_config_db#(virtual fifoif)::get(this, "", "vif", cfg.vif))
      `uvm_fatal(get_type_name(), "vif not found in config_db")
    uvm_config_db#(fifo_config)::set(this, "*", "fifo_config", cfg);
    env = fifo_env::type_id::create("env", this);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction

endclass

class test_sanity_write_read extends fifo_base_test;
  `uvm_component_utils(test_sanity_write_read)
  function new(string name = "test_sanity_write_read", uvm_component parent);
    super.new(name, parent);
  endfunction
  task run_phase(uvm_phase phase);
    write_burst_seq wr = write_burst_seq::type_id::create("wr");
    read_burst_seq  rd = read_burst_seq::type_id::create("rd");
    phase.raise_objection(this);
    wr.num_writes = 4; wr.start(env.inp_agt.seqr);
    rd.num_reads = 4; rd.start(env.inp_agt.seqr);
    phase.drop_objection(this);
  endtask
endclass

class test_fill_to_full extends fifo_base_test;
  `uvm_component_utils(test_fill_to_full)
  function new(string name = "test_fill_to_full", uvm_component parent);
    super.new(name, parent);
  endfunction
  task run_phase(uvm_phase phase);
    fill_to_full_seq seq = fill_to_full_seq::type_id::create("seq");
    phase.raise_objection(this);
    seq.margin = 8; seq.start(env.inp_agt.seqr);
    phase.drop_objection(this);
  endtask
endclass

class test_drain_to_empty extends fifo_base_test;
  `uvm_component_utils(test_drain_to_empty)
  function new(string name = "test_drain_to_empty", uvm_component parent);
    super.new(name, parent);
  endfunction
  task run_phase(uvm_phase phase);
    fill_to_full_seq   fill = fill_to_full_seq::type_id::create("fill");
    drain_to_empty_seq drain = drain_to_empty_seq::type_id::create("drain");
    phase.raise_objection(this);
    fill.margin = 0; fill.start(env.inp_agt.seqr);
    drain.margin = 8; drain.start(env.inp_agt.seqr);
    phase.drop_objection(this);
  endtask
endclass

class test_simultaneous_rw extends fifo_base_test;
  `uvm_component_utils(test_simultaneous_rw)
  function new(string name = "test_simultaneous_rw", uvm_component parent);
    super.new(name, parent);
  endfunction
  task run_phase(uvm_phase phase);
    simultaneous_rw_seq seq = simultaneous_rw_seq::type_id::create("seq");
    phase.raise_objection(this);
    seq.num_cycles = `RAM_DEPTH; seq.start(env.inp_agt.seqr);
    phase.drop_objection(this);
  endtask
endclass


class test_wrap_around extends fifo_base_test;
  `uvm_component_utils(test_wrap_around)
  function new(string name = "test_wrap_around", uvm_component parent);
    super.new(name, parent);
  endfunction
  task run_phase(uvm_phase phase);
    wrap_around_seq seq = wrap_around_seq::type_id::create("seq");
    phase.raise_objection(this);
    seq.num_wraps = 4;  seq.start(env.inp_agt.seqr);
    phase.drop_objection(this);
  endtask
endclass

class test_en_without_cs extends fifo_base_test;
  `uvm_component_utils(test_en_without_cs)
  function new(string name = "test_en_without_cs", uvm_component parent);
    super.new(name, parent);
  endfunction
  task run_phase(uvm_phase phase);
    en_without_cs_seq seq = en_without_cs_seq::type_id::create("seq");
    phase.raise_objection(this);
    repeat (10) seq.start(env.inp_agt.seqr);
    phase.drop_objection(this);
  endtask
endclass


class test_random_rw extends fifo_base_test;
  `uvm_component_utils(test_random_rw)
  function new(string name = "test_random_rw", uvm_component parent);
    super.new(name, parent);
  endfunction
  task run_phase(uvm_phase phase);
    random_rw_seq seq = random_rw_seq::type_id::create("seq");
    phase.raise_objection(this);
    seq.num_items = 2000; seq.start(env.inp_agt.seqr);
    phase.drop_objection(this);
  endtask
endclass

`endif
