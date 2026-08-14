`ifndef DRIVER
`define DRIVER

`include "uvm_macros.svh"
 import uvm_pkg::*;
`include "fifo_config.sv"
`include "fifo_seq_item.sv"
 
 class driver extends uvm_driver #(trans);
  `uvm_component_utils(driver)

  virtual fifoif.DRV dvif;
  fifo_config mcfg;

  function new(string name = "driver", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(fifo_config)::get(this, "", "fifo_config", mcfg))
      `uvm_fatal(get_type_name(), "Driver get failed")
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    dvif = mcfg.vif;
  endfunction

  task run_phase(uvm_phase phase);
    dvif.drv_cb.wr_cs  <= 1'b0;
    dvif.drv_cb.rd_cs  <= 1'b0;
    dvif.drv_cb.wr_en  <= 1'b0;
    dvif.drv_cb.rd_en  <= 1'b0;
    dvif.drv_cb.data_in <= '0;

 wait (dvif.rst == 1'b0);
  @(dvif.drv_cb);

    forever begin
      seq_item_port.get_next_item(req);
      drive(req);
      seq_item_port.item_done();
    end
  endtask

  task drive(trans data2duv);
    @(dvif.drv_cb);
    dvif.drv_cb.wr_cs   <= data2duv.wr_cs;
    dvif.drv_cb.rd_cs   <= data2duv.rd_cs;
    dvif.drv_cb.wr_en   <= data2duv.wr_en;
    dvif.drv_cb.rd_en   <= data2duv.rd_en;
    dvif.drv_cb.data_in <= data2duv.data_in;
 `uvm_info("DRIVER", $sformatf("Driver: %s", data2duv.convert2string()), UVM_LOW)
  endtask
endclass
`endif

