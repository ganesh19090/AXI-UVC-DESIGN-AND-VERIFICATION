module top;
	logic aclk;
	logic arstn;

	//generation of aclk at 100MHz (10.0ns)
	initial aclk=0;
	always #5 aclk=~aclk;

	//active low rst
	initial begin
		arstn=0;
		@(posedge aclk);
		arstn=1;
	end
	
	//interface instantation
	axi_if axi_pif(aclk,arstn);

	//DUT instantation
	axi_mem_slave uut_axi_mem_slave(

		//GLOBAL SIGNALS
						.aclk	(axi_pif.aclk),
						.arstn	(axi_pif.arstn), //active low

		//WRITE ADDRESS CHANNEL
		 				.awid	(axi_pif.awid),
						.awaddr	(axi_pif.awaddr),
				 		.awlen	(axi_pif.awlen),
					 	.awsize	(axi_pif.awsize),
					 	.awburst	(axi_pif.awburst),
						.awvalid	(axi_pif.awvalid),
						.awready	(axi_pif.awready),
		
		//WRITE DATA CHANNEL
				 		.wid	(axi_pif.wid),
					 	.wdata	(axi_pif.wdata),
						.wstrb	(axi_pif.wstrb),
						.wlast	(axi_pif.wlast),
						.wvalid	(axi_pif.wvalid),
		 				.wready	(axi_pif.wready),

		//WRITE RESPONSE CHANNEL
						.bid	(axi_pif.bid),
						.bresp	(axi_pif.bresp),
						.bvalid	(axi_pif.bvalid),
						.bready	(axi_pif.bready),

		//READ ADDRERSS CHANNEL
						.arid	(axi_pif.arid),
						.araddr	(axi_pif.araddr),
						.arlen	(axi_pif.arlen),	
						.arsize	(axi_pif.arsize),
						.arburst	(axi_pif.arburst),
						.arvalid	(axi_pif.arvalid),
						.arready	(axi_pif.arready),

		//READ DATA CHANNEL
						.rid	(axi_pif.rid),
	 					.rdata	(axi_pif.rdata),
					 	.rresp	(axi_pif.rresp),
		 				.rlast	(axi_pif.rlast),
						.rvalid	(axi_pif.rvalid),
		 				.rready	(axi_pif.rready)
);



	initial begin
		run_test("axi_base_test");
	end

	initial begin
		uvm_config_db#(virtual axi_if)::set(null,"*","vif",axi_pif); //passing the axi_pif handle into config data base having name as vif,so in rest of placing in axi tb drv and mon we ge method using same name vif
	end
	

//	initial begin
//		#1000;
//		$finish;
//	end
//	initial begin
//	//waveform dump
//			$fsdbDumpfile("axi.fsdb");
//			$fsdbDumpvars(0,top);
//			$fsdbDumpMDA(0,top.uut_axi_mem_slave.mem);
//	end
endmodule
