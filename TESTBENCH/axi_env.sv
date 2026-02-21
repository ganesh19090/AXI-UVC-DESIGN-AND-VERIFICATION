class axi_env extends uvm_env;

	//factory registration
	`uvm_component_utils(axi_env);

	//new constructor
	`COMP_CONS
	
	axi_agent axi_agent_h;
	axi_sbd   axi_sbd_h;
	
	//build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info(get_type_name(),"build_phase verified",UVM_NONE)
		axi_agent_h=axi_agent::type_id::create("axi_agent_h",this);
		axi_sbd_h=axi_sbd::type_id::create("axi_sbd_h",this);
	endfunction

	//connect_phase
	function void connect_phase(uvm_phase phase);
	
		`uvm_info(get_type_name(),"connect_phase is verified",UVM_NONE)
		axi_agent_h.axi_mon_h.axi_ap_h.connect(axi_sbd_h.fifo.analysis_export);
	endfunction


endclass
