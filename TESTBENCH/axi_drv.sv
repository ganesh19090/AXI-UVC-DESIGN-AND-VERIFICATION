class axi_drv extends uvm_driver#(axi_tx);
	
	//factory registration
	`uvm_component_utils(axi_drv)
		
	virtual axi_if axi_vif;
	axi_tx tx;

	//new constructor
	`COMP_CONS

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual axi_if)::get(this,"","vif",axi_vif))

		`uvm_error(get_type_name(),"FALIED TO RETRIVE CIF HANDLE FROM CONFIG DB")
		tx=axi_tx::type_id::create("tx",this);
	endfunction

	task run_phase(uvm_phase phase);
		`uvm_info(get_type_name(),"run_phase is verified",UVM_NONE)
		forever begin
			seq_item_port.get_next_item(req);//drv to sqr communication
			req.print();
			drive_tx(req);
			seq_item_port.item_done();
		end
		
	endtask


	task drive_tx(axi_tx tx);
		fork
		if(tx.wr_rd ==1) begin
			//WRITE ADDRESS PHASE
			write_address_channel(tx);
			//WRITE DATA PHASE
			write_data_channel(tx);
			//WRITE RESPONSE PHASE
			write_response_channel(tx);
			
		end
		else begin
			//READ ADDRESS PHASE
			read_address_channel(tx);
			//READ DATA PHASE
			read_data_channel(tx);
		end
		join_any
	endtask

	task write_address_channel(axi_tx tx);
		`uvm_info("AW","write_address_channel START",UVM_NONE)
			@(axi_vif.axi_drv_cb);
		axi_vif.axi_drv_cb.awid <= tx.id;
		axi_vif.axi_drv_cb.awaddr <= tx.addr;
		axi_vif.axi_drv_cb.awlen <= tx.len;
		axi_vif.axi_drv_cb.awsize <= tx.size;
		axi_vif.axi_drv_cb.awburst <= tx.burst;
		axi_vif.axi_drv_cb.awvalid <= 1;

		tx.print_aw();
		
		do begin
			@(axi_vif.axi_drv_cb);
		end
		while(axi_vif.axi_drv_cb.awready==0);//do a particularcondition until the condition is true cause valid and ready occurs at posedge clk 
		@(axi_vif.axi_drv_cb);
		axi_vif.axi_drv_cb.awvalid <= 0;
		`uvm_info("AW","write_address_channel END",UVM_NONE)
	endtask


	task write_data_channel(axi_tx tx);
		`uvm_info("W","write_data_channel START",UVM_NONE)
		for(int i=0; i<=tx.len;i++) begin  //TODO LEN+1
			//@(axi_vif.axi_drv_cb);
			axi_vif.axi_drv_cb.wid <= tx.id;
			axi_vif.axi_drv_cb.wdata <= tx.wdata[i];
			axi_vif.axi_drv_cb.wstrb <= tx.strb;
		if(i==tx.len) begin
			axi_vif.axi_drv_cb.wlast <= (i==tx.len); //<=1
		end
			tx.print_w();
			axi_vif.axi_drv_cb.wvalid <= 1;

			do begin
				@(axi_vif.axi_drv_cb);
			end
			while(axi_vif.axi_drv_cb.wready == 0);
		end
				//	@(axi_vif.axi_drv_cb);
				axi_vif.axi_drv_cb.wvalid <= 0;
				axi_vif.axi_drv_cb.wlast  <= 0;
	//	end
			`uvm_info("W","write_data_channel END",UVM_NONE)
	endtask


	task write_response_channel(axi_tx tx);
	 	// @(axi_vif.axi_drv_cb);	
		//keep the master ready
		axi_vif.axi_drv_cb.bready <= 1;
		`uvm_info("B","write_response_channel START",UVM_NONE)
		
		//wait for valid from slave
		do begin
			@(axi_vif.axi_drv_cb);
			`uvm_info("B","Waiting for BVALID...",UVM_NONE)
		end while(axi_vif.axi_drv_cb.bvalid==0 && axi_vif.axi_drv_cb.bready==0);

		tx.id = axi_vif.axi_drv_cb.bid;
		tx.resp = resp_t'(axi_vif.axi_drv_cb.bresp); //cast because resp is logic and bresp is bit  
		//next clk edge deassert the ready

		tx.print_b();

		@(axi_vif.axi_drv_cb);
		axi_vif.axi_drv_cb.bready <= 0;
		`uvm_info("B","write_response_Channel END",UVM_NONE)
	endtask

		task read_address_channel(axi_tx tx);
		`uvm_info("AR","read_address_channel START",UVM_NONE)
			@(axi_vif.axi_drv_cb);
		axi_vif.axi_drv_cb.arid <= tx.id;
		axi_vif.axi_drv_cb.araddr <= tx.addr;
		axi_vif.axi_drv_cb.arlen <= tx.len;
		axi_vif.axi_drv_cb.arsize <= tx.size;
		axi_vif.axi_drv_cb.arburst <= tx.burst;
		axi_vif.axi_drv_cb.arvalid <= 1;

		tx.print_ar();
		
		do begin
			@(axi_vif.axi_drv_cb);
		end
		while(axi_vif.axi_drv_cb.arready==0);//do a particularcondition until the condition is true cause valid and ready occurs at posedge clk 
		@(axi_vif.axi_drv_cb);
		axi_vif.axi_drv_cb.arvalid <= 0;
		`uvm_info("AR","read_address_channel END",UVM_NONE)
	endtask

	task read_data_channel(axi_tx tx);
		`uvm_info("R","read_data_channel start",UVM_NONE)
	 	 @(axi_vif.axi_drv_cb);	
		//keep the master ready
		axi_vif.axi_drv_cb.rready <= 1;
				tx.rdata = new[tx.len+1];
		for(int i=0;i<=tx.len;i++) begin
			do begin
				@(axi_vif.axi_drv_cb);
			end while(axi_vif.axi_drv_cb.rvalid==0);
				//tx.rdata = new[tx.len+1];
				//@(axi_vif.axi_drv_cb);
				tx.id = axi_vif.axi_drv_cb.rid;
				tx.rdata[i] = axi_vif.axi_drv_cb.rdata;
				tx.resp = resp_t'(axi_vif.axi_drv_cb.rresp);
				 if(i == tx.len+1) begin
				        if(axi_vif.axi_drv_cb.rlast != 1'b1)
				            `uvm_error("R","RLAST not asserted on final beat")
				    	 end
						 else begin
							tx.print_r();
						 end
		end
	//axi_vif.axi_drv_cb.rready<=1;
		@(axi_vif.axi_drv_cb);
		axi_vif.axi_drv_cb.rready<=0;
		 `uvm_info("R","read_data_channel end",UVM_NONE)
	endtask

endclass
