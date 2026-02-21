class axi_tx extends uvm_sequence_item;
	
	//property
	rand bit [3:0] id;
	rand bit [`ADDR_WIDTH-1:0] addr;
	rand bit [3:0] len;
	rand bit [2:0] size;
	rand burst_t burst;
	rand bit [`DATA_WIDTH-1:0] wdata[];
		 bit [`DATA_WIDTH-1:0] rdata[];
	rand bit [`STRB_WIDTH-1:0] strb;
	rand resp_t resp;	
	rand bit last[];
	rand bit wlast;
	rand bit rlast;
	
	rand bit wr_rd; //driver to know which phases to drive based on randomization

	//registration
	`uvm_object_utils_begin(axi_tx)
		`uvm_field_int(id,UVM_ALL_ON)
		`uvm_field_int(addr,UVM_ALL_ON)
		`uvm_field_int(len,UVM_ALL_ON)
		`uvm_field_int(size,UVM_ALL_ON)
		`uvm_field_enum(burst_t,burst,UVM_ALL_ON)
		`uvm_field_array_int(wdata,UVM_ALL_ON)
		`uvm_field_array_int(rdata,UVM_ALL_ON)
		`uvm_field_int(strb,UVM_ALL_ON)
		`uvm_field_enum(resp_t,resp,UVM_ALL_ON)
		`uvm_field_array_int(last,UVM_ALL_ON)
	`uvm_object_utils_end	

	//new constructor
	`OBJ_CONS

	//constraint

	constraint data_size_c{
		wdata.size()==len+1;
	}

	constraint addr_width_c{
		addr inside {[0:4095]};
	}
	
	constraint resp_c{
		resp==OKAY;
	}

	function void print_aw();
		`uvm_info("AXI_AW",$sformatf(">>>AXI WR ADDRESS CHANNEL @ %0t <<< \n AWID=%h \n AWADDR=%h \n AWLEN=%h \n AWSIZE=%h \n AWBURST=%s",
		$realtime,id,addr,len,size,burst),UVM_NONE)
	endfunction

	function void print_w();
		`uvm_info("AXI_W",$sformatf(">>>AXI WR DATA CHANNEL @ %0t <<< \n WID=%h \n WSTRB=%h \n WDATA=%p \n WLAST=%h",$realtime,id,strb,wdata,wlast),UVM_NONE)
	endfunction
	

	function void print_b();
		`uvm_info("AXI_B",$sformatf(">>> AXI WR RESPONSE CHANNEL @ %0t <<< \n BID=%h \n BRESP=%h",$realtime,id,resp),UVM_NONE)
	endfunction


	function void print_ar();
		`uvm_info("AXI_AR",$sformatf(">>>AXI AR ADDRESS CHANNEL @ %0t <<< \n ARID=%h \n ARADDR=%h \n ARLEN=%h \n ARSIZE=%h \n ARBURST=%s",
		$realtime,id,addr,len,size,burst),UVM_NONE)
	endfunction

	function void print_r();
		`uvm_info("AXI_R",$sformatf(">>> AXI R DATA CHANNEL @ %0t <<< \n RID=%h \n RRESP=%h \n RDATA=%p \n RLAST=%h",$realtime,id,resp,rdata,rlast),UVM_NONE)
	endfunction

	
	endclass
