class axi_sbd extends uvm_scoreboard;
	
	//factory_registration
	`uvm_component_utils(axi_sbd)

	//fifo instead of analysis_imp
	uvm_tlm_analysis_fifo #(axi_tx) fifo;

	//SBD AA MEM
	bit [7:0] mem_AA [int];
	//SBD AA of Q
	bit [31:0] mem_AA_Q [int][$];
	
	bit [3:0] tx_len;

	int match_count, miss_match_count;

	//new constructor
	`COMP_CONS

	//build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info(get_type_name(),"build_phase is verified",UVM_NONE)
		fifo= new("fifo",this);
	endfunction

	task run_phase(uvm_phase phase);
		axi_tx tx;
		
		`uvm_info("AXI_SBD","SBD START",UVM_NONE)
		forever begin
			fifo.get(tx); 
			`uvm_info("AXI SBD", "received tx from mon",UVM_NONE)
			tx_len = tx.len;
			process_tx(tx);
		end
	endtask
	task process_tx(axi_tx tx);
		bit [`ADDR_WIDTH-1:0] current_addr;
		bit [`ADDR_WIDTH-1:0] expected_data;
		int total_expected_beats;
		//WR_TX
		if(tx.wr_rd==1) begin
			current_addr	= tx.addr;
			case(tx.burst)
			INCR:begin
				for(int i=0;i<tx.len+1;i++) begin
					for( int strb=0;strb<`STRB_WIDTH;strb++) begin
						if(tx.strb[strb]) begin
							mem_AA[current_addr + strb]	= tx.wdata[i][8*strb+:8];
						end

					end
				//next_addr(current_addr,tx.len,tx.size,INCR,current_addr);	
				current_addr = current_addr + (1 << tx.size);
				
				end

			end
			
			FIXED: begin
				foreach(tx.wdata[i]) begin
					mem_AA_Q[current_addr].push_back(tx.wdata[i]);
				//	next_addr(current_addr,  tx.len,tx.size,FIXED,current_addr);
				current_addr = current_addr;
				end
			end
			
			WRAP: begin


			end

			RSVD: begin
				`uvm_error("MEM_SBD","WILL NOT BE DONE")
			end
			endcase	
		end
	else begin
		//RD_TX
		current_addr=tx.addr;
		if(tx.wr_rd == 0) begin
  			 total_expected_beats += (tx.len + 1);
		end
		case(tx.burst)
		INCR: begin
			for(int i=0;i<tx.len+1;i++) begin
				expected_data={mem_AA[current_addr+3],mem_AA[current_addr+2],mem_AA[current_addr+1],mem_AA[current_addr]};
				if(expected_data==tx.rdata[i]) begin

					match_count++;
				end
				else begin
					miss_match_count++;
					`uvm_error("AXI_SBD_ERR",
								$sformatf("AXI_RD_BURST=%s ADDR=%h actual DATA[%h]=%h miss_match with expected_data=%h",tx.burst,tx.addr,i,tx.rdata[i],expected_data))
				end
				//next_addr(current_addr,tx.len,tx.size,INCR,current_addr);
				current_addr = current_addr + (1 << tx.size);
			end
		end

		FIXED: begin
			foreach(tx.rdata[i]) begin
				expected_data=mem_AA_Q[tx.addr].pop_front();
				if(expected_data==tx.rdata[i]) begin
					match_count++;
				end
				else begin
					miss_match_count++;
					`uvm_error("AXI_SBD_ERR",
								$sformatf("AXI_RD_BURST=%s ADDR=%h actual DATA[%h]=%h miss_match with expected_data=%h",tx.burst,tx.addr,i,tx.rdata[i],expected_data))
				end
				//next_addr(current_addr,tx.len,tx.size,FIXED,current_addr);
				current_addr = current_addr;
			end
		end
		

		WRAP: begin

		end

		RSVD: begin
			`uvm_error("MEM_SBD","WILL NOT BE DONE")
		end
		endcase	
	end
	endtask
 
 	function void report_phase(uvm_phase phase);
		string test_name;
		//tx_len = tx.len;
		test_name=uvm_top.get_child("uvm_test_top").get_type_name();

		if(miss_match_count==0 && match_count>0) begin
			`uvm_info("AXI_SBD_TEST_STATUS",
					$sformatf("miss_match_count=%h match_count=%h ",miss_match_count,match_count),
					UVM_NONE)

			`uvm_info("AXI_SBD_TEST_STATUS",
					$sformatf("\n===========\n TEST %S PASSED  \n============", test_name),
					UVM_NONE)
		end
		else begin
			`uvm_info("AXI_SBD_TEST_STATUS",
					$sformatf("miss_match_count=%h match_count=%h ",miss_match_count,match_count),
					UVM_NONE)
			`uvm_fatal("AXI_SBD_TEST_STATUS",
					$sformatf("\n===========\n TEST %S FAILED  \n============", test_name))
		end
	endfunction

endclass





