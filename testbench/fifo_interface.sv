`ifndef INTF
`define INTF

`include "defines.svh"
interface fifoif(input bit clk);
 logic rst, wr_cs,rd_cs,rd_en,wr_en;
 logic [`DATA_WIDTH-1:0] data_in;
 logic [`DATA_WIDTH-1:0] data_out;
 logic full, empty;

clocking drv_cb @(posedge clk);
  default input #1 output #1;
  output rst,wr_cs,rd_cs,wr_en,rd_en,data_in;
endclocking

clocking inp_mon_cb @(posedge clk);
  default input #1 output #1;
  input  rst,wr_cs,rd_cs,wr_en,rd_en,data_in,full;
endclocking

clocking out_mon_cb @(posedge clk);
  default input #1 output #1;
  input  rst,wr_cs,rd_cs,wr_en,rd_en,data_in,data_out,full,empty;
endclocking

modport DRV(input rst, clocking drv_cb);
modport INPMON(clocking inp_mon_cb);
modport OUTMON(clocking out_mon_cb);
endinterface

`endif
