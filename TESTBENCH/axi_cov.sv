class axi_cov extends uvm_subscriber#(axi_tx);

	//factory registration
	`uvm_component_utils(axi_cov)
		
	axi_tx tx;

	//new constructor
//	`COMP_CONS
	
	covergroup axi_cg;

		WR_RD_CP : coverpoint tx.wr_rd {
 			 bins write = {1};
  			 bins read  = {0};
		}
		ADDR_CP:coverpoint (tx.addr){
			bins addr={[0:4095]};
		}

		//LEN
		LEN_CP:coverpoint (tx.len){
		//	bins len_1 = {0};
			bins len_2_4 = {[1:3]};
		//	bins len_8 = {7};
		}

		//SIZE
		SIZE_CP:coverpoint (tx.size){
		//	bins BYTE  = {0};  // 1 byte
      	//	bins half  = {1};  // 2 bytes
     		bins word  = {2};  // 4 bytes
     	//	bins dword = {3};  // 8 bytes
		}
		
		//BURST
		BURST_CP:coverpoint (tx.burst) {
			bins fixed = {FIXED};
			bins incr = {INCR};
			bins wrap = {WRAP};

		}

		//RESPONSE
		 RESP_CP : coverpoint (tx.resp) {
     			 bins okay   = {OKAY};
     		//	 bins exokay = {EXOKAY};
     		//	 bins slverr = {SLVERR};
      			 bins decerr = {DECERR};
    }
	endgroup


	function new(string name="",uvm_component parent);
		super.new(name,parent);
		axi_cg=new();
	endfunction

	function void write(T t);
	$cast(tx,t);
	axi_cg.sample();
	`uvm_info(get_type_name(),"WRITE OF COV CALLED",UVM_NONE)
	endfunction

	
endclass
