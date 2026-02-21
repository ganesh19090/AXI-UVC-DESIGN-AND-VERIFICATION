interface axi_if(input logic aclk,arstn);
		

		//WRITE ADDRESS CHANNEL
		logic			 [3:0] 	awid;
		logic [`ADDR_WIDTH-1:0]	awaddr;
		logic			 [3:0] 	awlen;
		logic			 [2:0] 	awsize;
		logic			 [1:0] 	awburst;
		logic					awvalid;
		logic					awready;
		
		//WRITE DATA CHANNEL
		logic    		[3:0]	wid;
		logic [`DATA_WIDTH-1:0]	wdata;
		logic [`STRB_WIDTH-1:0]	wstrb;
		logic 					wlast;
		logic 					wvalid;
		logic 					wready;

		//WRITE RESPONSE CHANNEL
		logic		 	[3:0]	bid;
		logic 			[1:0]	bresp;
		logic 					bvalid;
		logic 					bready;

		//READ ADDRERSS CHANNEL
		logic			 [3:0] 	arid;
		logic [`ADDR_WIDTH-1:0]	araddr;
		logic			 [3:0]  arlen;
		logic 			  [2:0] arsize;
		logic 			  [1:0] arburst;
		logic					arvalid;
		logic					arready;

		//READ DATA CHANNEL
		logic			 [3:0] 	rid;
		logic[`DATA_WIDTH-1:0]	rdata;
		logic			 [1:0] 	rresp;
		logic		 			rlast;
		logic					rvalid;
		logic		 			rready;

		//driver clocking block
		clocking axi_drv_cb@(posedge aclk);
			default input #0 output #1;
			
			output			  	awid;
			output 				awaddr;
			output			 	awlen;
			output			  	awsize;
			output			  	awburst;
			output				awvalid;
			input				awready;
			
			//WRITE DATA CHANNEL
			output    			wid;
			output			    wdata;
			output 				wstrb;
			output 				wlast;
			output 				wvalid;
			input 				wready;
	
			//WRITE RESPONSE CHANNEL
			input		 		bid;
			input 				bresp;
			input 				bvalid;
			output 				bready;
	
			//READ ADDRERSS CHANNEL
			output			  	arid;
			output			 	araddr;
			output			    arlen;
			output 		    	arsize;
			output 		    	arburst;
			output			   	arvalid;
			input				arready;
	
			//READ DATA CHANNEL
			input				rid;
			input				rdata;
			input				rresp;
			input		 		rlast;
			input			#1	rvalid;
			output	 			rready;
	
	
	
		endclocking
		
		clocking axi_mon_cb@(posedge aclk); //TODO input #0
			default input #0;
		
		//WRITE ADDR CHANNEL
			input		awid;
			input		awaddr;
			input		awlen;
			input		awsize;
			input		awburst;
			input		awvalid;
			input		awready;
    		
		//WRITE DATA CHANNEL	
			input 		wid;
			input		wdata;
			input		wstrb;
			input		wlast;
			input		wvalid;
			input		wready;
    	
		//WRITE RESPONSE CHANNEL
			input 		bid;
			input		bresp;
			input	#1	bvalid;
			input		bready;

		//READ ADDR CHANNEL
    		input 		arid;
			input		araddr;
			input		arlen;
			input		arsize;
			input		arburst;
			input		arvalid; 
			input		arready;
   		  
		 //READ DATA CHANNEL 
			input 		rid;
			input		rdata;
			input		rresp;
			input		rlast;
			input		rvalid;
			input		rready;
	
		endclocking

endinterface

