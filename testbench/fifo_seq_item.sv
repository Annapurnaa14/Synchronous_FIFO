`ifndef SEQITEM
`define SEQITEM

`include"defines.svh"
`include"uvm_macros.svh"
import uvm_pkg::*;

class trans extends uvm_sequence_item;
`uvm_object_utils(trans)

rand bit rst;
rand bit wr_cs,rd_cs,wr_en,rd_en;
rand bit[`DATA_WIDTH-1:0]data_in;
bit[`DATA_WIDTH-1:0]data_out;
bit full,empty;
bit wr_qualified;
bit rd_qualified;

function new(string name="trans");
super.new(name);
endfunction


constraint writechipsel{(wr_en==1) -> (wr_cs==1);}
constraint readchipsel {(rd_en==1) -> (rd_cs==1);}
constraint dinval{ data_in inside {[0:255]};}

  virtual function string convert2string();
    return $sformatf(" Rst =%0b  |  Wr_cs=%0b | Wr_en=%0b | Rd_cs=%0b | Rd_en=%0b |  Data_in=0x%0h  | Data_out=0x%0h | Full=%0b | Empty=%0b ",rst, wr_cs, wr_en, rd_cs, rd_en, data_in, data_out, full, empty);
  endfunction
endclass

`endif
