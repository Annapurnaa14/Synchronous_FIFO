`ifndef SEQUENCES
`define SEQUENCES

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "fifo_seq_item.sv"

class fifo_base_seq extends uvm_sequence #(trans);
  `uvm_object_utils(fifo_base_seq)
  function new(string name ="fifo_base_seq");
    super.new(name);
  endfunction

  task send(bit wr_cs, wr_en, rd_cs, rd_en, bit [`DATA_WIDTH-1:0] data_in);
    trans t = trans::type_id::create("t");
    start_item(t);
    if (!t.randomize() with {
          rst == 0; wr_cs  == local::wr_cs; wr_en  == local::wr_en; rd_cs  == local::rd_cs; rd_en  == local::rd_en; data_in == local::data_in;})
      `uvm_error(get_type_name(), "randomize failed")
    finish_item(t);
  endtask
endclass

class write_burst_seq extends fifo_base_seq;
  `uvm_object_utils(write_burst_seq)
  rand int num_writes = 4;
  function new(string name = "write_burst_seq");
    super.new(name);
  endfunction
  task body();
    for (int i = 0; i < num_writes; i++)
      send(1, 1, 0, 0, i[`DATA_WIDTH-1:0]);
  endtask
endclass

class read_burst_seq extends fifo_base_seq;
  `uvm_object_utils(read_burst_seq)
  rand int num_reads = 4;
  function new(string name = "read_burst_seq");
    super.new(name);
  endfunction
  task body();
    for (int i = 0; i < num_reads; i++)
      send(0, 0, 1, 1, '0);
  endtask
endclass

class fill_to_full_seq extends fifo_base_seq;
  `uvm_object_utils(fill_to_full_seq)
  int margin = 4;
  function new(string name = "fill_to_full_seq");
    super.new(name);
  endfunction

  task body();
    for (int i = 0; i < (`RAM_DEPTH + margin); i++)
      send(1, 1, 0, 0, i[`DATA_WIDTH-1:0]);
  endtask
endclass

class drain_to_empty_seq extends fifo_base_seq;
  `uvm_object_utils(drain_to_empty_seq)
  int margin = 4;
  function new(string name = "drain_to_empty_seq");
    super.new(name);
  endfunction

  task body();
    for (int i = 0; i < (`RAM_DEPTH + margin); i++)
      send(0,0,1,1,'0);
  endtask
endclass

class simultaneous_rw_seq extends fifo_base_seq;
  `uvm_object_utils(simultaneous_rw_seq)
  rand int num_cycles = `RAM_DEPTH;

  function new(string name = "simultaneous_rw_seq");
    super.new(name);
  endfunction

  task body();
       send(1, 1, 0, 0, 8'hFF);
    for (int i = 0; i < num_cycles; i++)
      send(1, 1, 1, 1, i[`DATA_WIDTH-1:0]);
  endtask
endclass

class wrap_around_seq extends fifo_base_seq;
  `uvm_object_utils(wrap_around_seq)
  rand int num_wraps = 3;
  function new(string name = "wrap_around_seq");
    super.new(name);
  endfunction

  task body();
    write_burst_seq wr = write_burst_seq::type_id::create("wr");
    read_burst_seq  rd = read_burst_seq::type_id::create("rd");
    for (int w = 0; w < num_wraps; w++) begin
      wr.num_writes = `RAM_DEPTH;
      wr.start(m_sequencer);
      rd.num_reads = `RAM_DEPTH;
      rd.start(m_sequencer);
    end
  endtask
endclass

class en_without_cs_seq extends fifo_base_seq;
  `uvm_object_utils(en_without_cs_seq)
  function new(string name = "en_without_cs_seq");
    super.new(name);
  endfunction

  task body();
    trans t = trans::type_id::create("t");
    start_item(t);
    if (!t.randomize() with {rst == 0; wr_cs == 0; wr_en == 0; rd_cs == 0; rd_en == 0;})
      `uvm_error(get_type_name(), "randomize failed")
    finish_item(t);
  endtask
endclass

class random_rw_seq extends fifo_base_seq;
  `uvm_object_utils(random_rw_seq)
  rand int num_items = 500;
  function new(string name = "random_rw_seq");
    super.new(name);
  endfunction
  task body();
    repeat (num_items) begin
      trans t = trans::type_id::create("t");
      start_item(t);
      if (!t.randomize() with { rst == 0; })
        `uvm_error(get_type_name(), "randomize failed")
      finish_item(t);
    end
  endtask
endclass


`endif
