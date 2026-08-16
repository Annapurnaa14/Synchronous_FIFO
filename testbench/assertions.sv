
`include "uvm_macros.svh"
import uvm_pkg::*;

`include "defines.svh"
module fifo_assertions (
  input logic clk,rst, wr_cs, wr_en, rd_cs, rd_en, full,empty,
  input logic [`DATA_WIDTH-1:0] data_in,data_out,
  input logic [`ADDR_WIDTH-1:0] wr_pointer, rd_pointer,
  input logic [`ADDR_WIDTH:0] status_cnt );

  logic wr_qual, rd_qual;
  assign wr_qual = wr_cs && wr_en && !full;
  assign rd_qual = rd_cs && rd_en && !empty;

property p_rst_clears;
    @(posedge clk)
    $rose(rst) |=> (full == 0 && empty == 1 && data_out == 0 && wr_pointer == 0 && rd_pointer == 0 && status_cnt == 0);
  endproperty
  assert property (p_rst_clears)

 property write_when_full;
    @(posedge clk) disable iff (rst)
    (wr_cs && wr_en && full) |=> ($stable(status_cnt) && $stable(wr_pointer));
  endproperty
assert property(write_when_full)

  property read_when_empty;
    @(posedge clk) disable iff (rst)
    (rd_cs && rd_en && empty) |=> ($stable(rd_pointer) && $stable(data_out));
  endproperty
assert property(read_when_empty)

  property p_simul_rw_cnt_stable;
    @(posedge clk) disable iff (rst)
    (wr_qual && rd_qual) |=> $stable(status_cnt);
  endproperty
  a_simul_rw_cnt_stable: assert property (p_simul_rw_cnt_stable)

 property p_write_status_inc;
    @(posedge clk) disable iff (rst)
    (wr_qual && !rd_qual) |=> (status_cnt == ($past(status_cnt) + 1));
  endproperty
  a_write_status_inc: assert property (p_write_status_inc)

  property p_read_status_dec;
    @(posedge clk) disable iff (rst)
    (rd_qual && !wr_qual) |=> (status_cnt == ($past(status_cnt) - 1));
  endproperty
  a_read_status_dec: assert property (p_read_status_dec)


endmodule
