class axi_base_test_fixed extends uvm_test;
	
	//factory registration
	`uvm_component_utils(axi_base_test_fixed);
	
	
	//new constructor
	`COMP_CONS

	axi_env axi_env_h;
	
	//build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		axi_env_h=axi_env::type_id::create("axi_env_h",this);
		`uvm_info(get_type_name(),"build_phase is verifed",UVM_NONE)
	endfunction

	//connect_phase
	function void connect_phase(uvm_phase phase);
	
	`uvm_info(get_type_name(),"connect_phase is verified",UVM_NONE)
	endfunction

	//start_of_simulation
	function void start_of_simulation_phase(uvm_phase phase);
		uvm_top.print_topology();
		`uvm_info(get_type_name(),"start_of_simulation phase is verified",UVM_NONE)

	endfunction

	//run_phase
	task run_phase(uvm_phase phase);
		axi_fixed_seq axi_fixed_seq_h;	
		`uvm_info(get_type_name(),"run_phase is verified",UVM_NONE)
		axi_fixed_seq_h=axi_fixed_seq::type_id::create("axi_fixed_seq",this);
		phase.raise_objection(this);

		phase.phase_done.set_drain_time(this,1000);
		//update seqeuncer path 
		axi_fixed_seq_h.start(axi_env_h.axi_agent_h.axi_sqr_h);
		

		phase.drop_objection(this);
	endtask


endclass

//-------------------------------------------------------------------------

class axi_base_test_incr extends uvm_test;
	
	//factory registration
	`uvm_component_utils(axi_base_test_incr);
	
	
	//new constructor
	`COMP_CONS

	axi_env axi_env_h;
	
	//build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		axi_env_h=axi_env::type_id::create("axi_env_h",this);
		`uvm_info(get_type_name(),"build_phase is verifed",UVM_NONE)
	endfunction

	//connect_phase
	function void connect_phase(uvm_phase phase);
	
	`uvm_info(get_type_name(),"connect_phase is verified",UVM_NONE)
	endfunction

	//start_of_simulation
	function void start_of_simulation_phase(uvm_phase phase);
		uvm_top.print_topology();
		`uvm_info(get_type_name(),"start_of_simulation phase is verified",UVM_NONE)

	endfunction

	//run_phase
	task run_phase(uvm_phase phase);
		axi_incr_seq axi_incr_seq_h;	
		`uvm_info(get_type_name(),"run_phase is verified",UVM_NONE)
		axi_incr_seq_h=axi_incr_seq::type_id::create("axi_incr_seq",this);
		phase.raise_objection(this);

		phase.phase_done.set_drain_time(this,1000);
		//update seqeuncer path 
		axi_incr_seq_h.start(axi_env_h.axi_agent_h.axi_sqr_h);
		

		phase.drop_objection(this);
	endtask


endclass
//-------------------------------------------------------------------------
