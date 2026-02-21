//UVM RELATED FILE
`include "uvm_pkg.sv"
import uvm_pkg::*;

//RTL
`include "axi_mem_slave.v"
`include "sync_fifo.v"

//VERIF
`include "axi_common.sv"
`include "axi_if.sv"
`include "axi_tx.sv"
`include "axi_sqr.sv"
`include "axi_drv.sv"
`include "axi_mon.sv"
`include "axi_cov.sv"
`include "axi_agent.sv"
`include "axi_sbd.sv"
`include "axi_env.sv"

//SEQ_LIB
`include "axi_seq_lib.sv"

//TEST_LIB
`include "axi_base_test.sv"
`include "top.sv"






