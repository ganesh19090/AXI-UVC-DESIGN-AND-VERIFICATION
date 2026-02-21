class axi_fixed_seq extends uvm_sequence#(axi_tx);
	
	//factory_registration
	`uvm_object_utils(axi_fixed_seq)

	//new constructor
	`OBJ_CONS


axi_tx tx;
	
	task body();
		`uvm_info(get_type_name(),"pre_body is executed",UVM_NONE);
		//randomize
	//	repeat(3) begin
		`uvm_do_with(req,{req.wr_rd==1;
						req.len==3;
						req.burst==FIXED;
						req.strb==4'b1111;
						req.size==3'h2;})
		$cast(tx,req);
		`uvm_do_with(req,{req.wr_rd==0;
						req.burst==FIXED;
						req.strb==4'b1111;
						req.len==tx.len;
						req.addr==tx.addr;
						req.size==3'h2;})
	//	end				
	endtask

endclass

//--------------------------------------------------------------------------

class axi_incr_seq extends uvm_sequence#(axi_tx);
	
	//factory_registration
	`uvm_object_utils(axi_incr_seq)

	//new constructor
	`OBJ_CONS


axi_tx tx;
	
	task body();
		`uvm_info(get_type_name(),"pre_body is executed",UVM_NONE);
		//randomize
	//	repeat(3) begin
		`uvm_do_with(req,{req.wr_rd==1;
						req.len==3;
						req.burst==INCR;
						req.strb==4'b1111;
						req.size==3'h2;})
		$cast(tx,req);
		`uvm_do_with(req,{req.wr_rd==0;
						req.burst==INCR;
						req.strb==4'b1111;
						req.len==tx.len;
						req.addr==tx.addr;
						req.size==3'h2;})
		//end				
	endtask

endclass

//--------------------------------------------------------------------------
