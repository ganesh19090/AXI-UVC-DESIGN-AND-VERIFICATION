class axi_mon extends uvm_monitor;
	
	//factory registration
	`uvm_component_utils(axi_mon)
		
	virtual axi_if axi_vif; //virtual interface
	uvm_analysis_port#(axi_tx) axi_ap_h;//analysis port declaration

	axi_tx tx;
	axi_tx wr_tx[int];	//assosiative array
	axi_tx rd_tx[int];

	//new consructor
	`COMP_CONS

	//build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		tx=axi_tx::type_id::create("tx");
		axi_ap_h=new("axi_ap_h",this);
		if(!uvm_config_db#(virtual axi_if)::get(this,"","vif",axi_vif))
		`uvm_error(get_type_name(),"RETRIVAL FAILED VIF FROM CONFIG DB")

	endfunction

	task run_phase(uvm_phase phase);
		`uvm_info(get_type_name(),"run_phase is verified",UVM_NONE)
		fork
			write_monitor();
			read_monitor();
		join
	endtask

	//WRITE MONITOR
	task write_monitor();
		//axi_tx tx;
	int aw_id;
	int w_id;
	int b_id;
	bit [`DATA_WIDTH-1:0] w_data_q[$]; //local queue to store data

		forever begin
			@(axi_vif.axi_mon_cb);

			//AW CHANNEL
			if(axi_vif.axi_mon_cb.awvalid && axi_vif.axi_mon_cb.awready) begin
				`uvm_info("AXI_MON_AW","write_address_channel START",UVM_NONE) //
				aw_id=axi_vif.axi_mon_cb.awid;
				wr_tx[aw_id]=axi_tx::type_id::create($sformatf("wr_tx[%0d]",aw_id));
				wr_tx[aw_id].wr_rd	= 1;
				//update the tx wr_rd bit to WR operation
				
				wr_tx[aw_id].id		= aw_id;
				wr_tx[aw_id].addr	= axi_vif.axi_mon_cb.awaddr;
				wr_tx[aw_id].len	= axi_vif.axi_mon_cb.awlen;
				wr_tx[aw_id].size	= axi_vif.axi_mon_cb.awsize;
				wr_tx[aw_id].burst	= burst_t'(axi_vif.axi_mon_cb.awburst);
				`uvm_info("AXI_MON_AW","write_address_channel END",UVM_NONE)

			end
			
			//W CHANNEL
			if(axi_vif.axi_mon_cb.wvalid && axi_vif.axi_mon_cb.wready) begin
				`uvm_info("AXI_MON_W","write_data_channel START",UVM_NONE)

				w_id				= axi_vif.axi_mon_cb.wid;
				
				//check the W is already exists in Assosarray
				if(wr_tx.exists(w_id)) begin //use exists method

					`uvm_info("AXI_MON_W","write_channel ID EXIST",UVM_NONE)
					
					//pushing the wdata to local queue
					w_data_q.push_back(axi_vif.axi_mon_cb.wdata);
					wr_tx[w_id].strb	= axi_vif.axi_mon_cb.wstrb;
					if(axi_vif.axi_mon_cb.wlast) begin
						wr_tx[w_id].wlast	= axi_vif.axi_mon_cb.wlast;
						wr_tx[w_id].wdata	= w_data_q;
                       
					//	delete the queue so cuurent wrdata will not be collected in next wr_tx while performing more tx repeat(n) for write and read
					//	w_data_q.delete();	
						`uvm_info("AXI_MON_W",
								$sformatf("FOR WID = %0d DATA =%p WLAST =%0d ",w_id,wr_tx[w_id].wdata,wr_tx[w_id].wlast),UVM_NONE)
					end
				end
				else begin

				end
				`uvm_info("AXI_MON_W","write_data_channel END",UVM_NONE)

			end
			// B channel
			if(axi_vif.axi_mon_cb.bvalid && axi_vif.axi_mon_cb.bready) begin
				`uvm_info("AXI_MON_B","write_response_channel START",UVM_NONE)
				b_id	= axi_vif.axi_mon_cb.bid;

				//check the W is already exists in Assosarray
				if(wr_tx.exists(b_id)) begin
					`uvm_info("AXI_MON_B","WRITE CHHANNEL ID EXISTS",UVM_NONE)
					wr_tx[b_id].resp 	= resp_t'(axi_vif.axi_mon_cb.bresp);
					`uvm_info("AXI_MON_WROTE_TX","MON going to WRITE TO SBD & COV",UVM_NONE)
					`uvm_info("AXI_MON_WROTE_TX",$sformatf("wr_tx[%0d]=%p",b_id,wr_tx[b_id]),UVM_NONE)

					//call the write method of monitor analysis port
					axi_ap_h.write(wr_tx[b_id]);
					`uvm_info("AXI_MON_WROTE_TX","MON_WROTE TX TO SBD & COV",UVM_NONE)
				end
				else begin

				end
				`uvm_info("AXI_MON_B","write_response_channel END",UVM_NONE)
			end
		end
 	endtask

	task read_monitor();

		int ar_id;
		int r_id;

		bit [`DATA_WIDTH-1:0] r_data_q[$];

		forever begin
			@(axi_vif.axi_mon_cb);
		//collecting AR Signals

			if(axi_vif.axi_mon_cb.arvalid && axi_vif.axi_mon_cb.arready) begin
				`uvm_info("AXI_MON_AR","read_channel AR START",UVM_NONE)
				ar_id	= axi_vif.axi_mon_cb.arid;
				rd_tx[ar_id]		= axi_tx::type_id::create($sformatf("rd_tx[%0d]",ar_id));
				rd_tx[ar_id].wr_rd	= 0;
				rd_tx[ar_id].id		= ar_id; 
				rd_tx[ar_id].addr	= axi_vif.axi_mon_cb.araddr;
				rd_tx[ar_id].len	= axi_vif.axi_mon_cb.arlen;
				rd_tx[ar_id].size	= axi_vif.axi_mon_cb.arsize;
				rd_tx[ar_id].burst 	= burst_t'(axi_vif.axi_mon_cb.arburst);

				`uvm_info("AXI_MON_AR","read_Channel AR END",UVM_NONE)
			end

			//R channel
			if(axi_vif.axi_mon_cb.rvalid && axi_vif.axi_mon_cb.rready) begin
				`uvm_info("AXI_MON_R","read_channel R START",UVM_NONE)
				r_id	= axi_vif.axi_mon_cb.rid;

				if(rd_tx.exists(r_id)) begin
					`uvm_info("AXI_MON_R","read_CHannel ID EXISTS",UVM_NONE)
					r_data_q.push_back(axi_vif.axi_mon_cb.rdata);
					rd_tx[r_id].rlast	= axi_vif.axi_mon_cb.rlast;
					if(rd_tx[r_id].rlast) begin

						rd_tx[r_id].rdata	= r_data_q;
						//	delete the queue so cuurent wrdata will not be collected in next wr_tx while performing more tx repeat(n) for write and read
					//	r_data_q.delete();	
						rd_tx[r_id].resp	= resp_t'(axi_vif.axi_mon_cb.rresp);
						`uvm_info("AXI_MON_R",
									$sformatf("FOR RID = %0d DATA = %p RLAST =%0d",r_id,rd_tx[r_id].rdata,rd_tx[r_id].rlast),
									UVM_NONE)
						`uvm_info("AXI_MON_WROTE_TX","MON going to write TO SBD AND COV",UVM_NONE)
						axi_ap_h.write(rd_tx[r_id]);
						`uvm_info("AXI_MON_WROTE_TX",
									$sformatf("rd_tx[%0d] = %p",r_id,rd_tx[r_id]),
									UVM_NONE)
					end
				end	
				`uvm_info("AXI_MON_R","read_channel R END",UVM_NONE)
			end
		end
	endtask
endclass	


	
	   
