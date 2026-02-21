#compile
vlog list.svh +incdir+C:/Users/91935/Desktop/uvm-1.2/src
#elaboration
vsim -novopt -suppress 12110 top \
-sv_lib C:/questasim64_10.7c/uvm-1.2/win64/uvm_dpi \
+UVM_TESTNAME=axi_base_test_incr

#add wave
#add wave -position insertpoint sim:/top/uut_axi_mem_slave/uut_sync_fifo/*
do wave.do

#run
run -all
