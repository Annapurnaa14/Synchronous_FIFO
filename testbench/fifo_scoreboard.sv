`ifndef SCOREBOARD
`define SCOREBOARD

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "defines.svh"
`include "fifo_seq_item.sv"

class scoreboard extends uvm_scoreboard;
        `uvm_component_utils(scoreboard)
        uvm_tlm_analysis_fifo #(trans) inp_mon_fifo;
        uvm_tlm_analysis_fifo #(trans) out_mon_fifo;
        trans inp_mon_xn;
        trans out_mon_xn;
  
   function new(string name="scoreboard",uvm_component parent);
        super.new(name,parent);
        inp_mon_fifo=new("inp_mon_fifo",this);
        out_mon_fifo=new("out_mon_fifo",this);
 endfunction
  
        bit [`DATA_WIDTH-1:0] exp_mem [`RAM_DEPTH];
        int unsigned exp_wr_ptr= 0;
        int unsigned exp_rd_ptr= 0;
        int unsigned exp_status_cnt= 0;
        bit [`DATA_WIDTH-1:0] exp_data_out = 0; 
        bit [`DATA_WIDTH-1:0] next_exp_data_out = 0;
        bit exp_full  = 0;
        bit exp_empty = 1;
  
 task run_phase(uvm_phase phase);
        forever
           begin
           inp_mon_fifo.get(inp_mon_xn);
           out_mon_fifo.get(out_mon_xn);
           ref_model(inp_mon_xn);
`uvm_info("REFERENCE_MODEL",$sformatf("REFERENCE_MODEL: %s",inp_mon_xn.convert2string()),UVM_NONE)
           check_Data(out_mon_xn);
`uvm_info("CHECKING OUTPUT ",$sformatf("CHECKING OUTPUT: %s",out_mon_xn.convert2string()),UVM_NONE)
          end
 endtask

 task print_mem();
        int unsigned addr;
        $display("---- MEM (valid entries: %0d) ----", exp_status_cnt);
        for (int unsigned k = 0; k < exp_status_cnt; k++) begin
          addr = (exp_rd_ptr + k) % `RAM_DEPTH;
          $display("mem[%0d]=0x%0h", addr, exp_mem[addr]);
        end
        $display("----------------------------------");
 endtask


virtual task validate_output();
        if(inp_mon_xn.compare(out_mon_xn))
        begin
          `uvm_info(get_type_name,$sformatf("DATA MATCH SUCCESSFUL"),UVM_NONE)
        end
        else
        begin
          `uvm_info(get_type_name,$sformatf("DATA MISMATCH"),UVM_NONE)
          `uvm_info(get_type_name,$sformatf("Expected Packet: %s",inp_mon_xn.convert2string()),UVM_NONE)
         `uvm_info(get_type_name,$sformatf("DUT Packet: %s",out_mon_xn.convert2string()),UVM_NONE)
        end
         endtask

 task check_Data(trans ch);
        begin
           $display("PTRS: wr_ptr=%0d rd_ptr=%0d status_cnt=%0d", exp_wr_ptr, exp_rd_ptr, exp_status_cnt);
           if(exp_data_out == ch.data_out)
                $display("\n DATA_OUT IS MATCHING");
           else
                $display("\n DATA_OUT IS NOT MATCHING : expected=0x%0h actual=0x%0h", exp_data_out, ch.data_out);
          if(exp_full == ch.full) $display("\n FULL IS MATCHING");
           else $display("\n FULL IS NOT MATCHING : expected=%0b actual=%0b", exp_full, ch.full);

          if(exp_empty == ch.empty) display("\n EMPTY IS MATCHING");
           else $display("\n EMPTY IS NOT MATCHING : expected=%0b actual=%0b", exp_empty, ch.empty);
        end
 endtask
  
 virtual task ref_model(trans t);
     bit wr_qual, rd_qual;
     exp_data_out = next_exp_data_out;
     if(t.rst)
       begin
         exp_wr_ptr= 0; exp_rd_ptr = 0;
         exp_status_cnt = 0;next_exp_data_out = 0;
         exp_full= 0;  exp_empty = 1;
       end
     else
       begin 
         exp_full  = (exp_status_cnt == `RAM_DEPTH);
         exp_empty = (exp_status_cnt == 0);
         wr_qual = t.wr_cs && t.wr_en && !exp_full;   
         rd_qual = t.rd_cs && t.rd_en && !exp_empty; 
         if(wr_qual)
           begin
             exp_mem[exp_wr_ptr] = t.data_in;
             $display("mem[%0d]=0x%0h (WRITE)", exp_wr_ptr, t.data_in);
             exp_wr_ptr = (exp_wr_ptr + 1) % `RAM_DEPTH;
             exp_status_cnt++;
           end
         if(rd_qual)
           begin
             next_exp_data_out = exp_mem[exp_rd_ptr];
             $display("mem[%0d]=0x%0h  (READ)", exp_rd_ptr, exp_mem[exp_rd_ptr]);
             exp_rd_ptr = (exp_rd_ptr + 1) % `RAM_DEPTH;
             exp_status_cnt--;
           end
         exp_full  = (exp_status_cnt == `RAM_DEPTH);
         exp_empty = (exp_status_cnt == 0);
       end

     $display("PTRS: wr_ptr=%0d rd_ptr=%0d status_cnt=%0d", exp_wr_ptr, exp_rd_ptr, exp_status_cnt);
 endtask
endclass

`endif
