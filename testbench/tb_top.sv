
`include "uvm_macros.svh"
import uvm_pkg::*;
`include "ram_des.sv"
`include "design.sv"
`include "defines.svh"
`include "fifo_interface.sv"
`include "fifo_seq_item.sv"
`include "fifo_config.sv"
`include "fifo_driver.sv"
`include "fifo_sequencer.sv"
`include "fifo_sequences.sv"
`include "inp_monitor.sv"
`include "input_agent.sv"
`include "output_monitor.sv"
`include "output_agent.sv"
`include "fifo_scoreboard.sv"
`include "fifo_subscriber.sv"
`include "fifo_env.sv"
`include "fifo_test.sv"
`include "assertions.sv"
bind syn_fifo fifo_assertions u_fifo_assertions (.*);

module top;

  bit clk;
  always #5 clk = ~clk;

  fifoif vif(clk);

  syn_fifo #(
    .DATA_WIDTH(`DATA_WIDTH),
    .ADDR_WIDTH(`ADDR_WIDTH)
  ) DUT (
    .clk     (clk),
    .rst     (vif.rst),
    .wr_cs   (vif.wr_cs),
    .rd_cs   (vif.rd_cs),
    .wr_en   (vif.wr_en),
    .rd_en   (vif.rd_en),
    .data_in (vif.data_in),
    .data_out(vif.data_out),
    .full    (vif.full),
    .empty   (vif.empty)
  );

  initial begin
    uvm_config_db#(virtual fifoif)::set(null, "*", "vif", vif);
  end

 initial begin
  vif.rst = 1'b1;
  repeat (3) @(posedge clk);
  vif.rst = 1'b0;
end

  initial begin
    run_test();
  end

  initial begin
    $dumpfile("fifo_tb.vcd");
    $dumpvars(0, top);
  end

endmodule
