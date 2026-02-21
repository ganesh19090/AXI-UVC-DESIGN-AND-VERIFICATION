
`define DATA_WIDTH 32
`define ADDR_WIDTH 32
`define STRB_WIDTH `DATA_WIDTH/8


module axi_mem_slave(

		//GLOBAL SIGNALS
		input aclk,
		input arstn, //active low

		//WRITE ADDRESS CHANNEL
		input [3:0] 	awid,
		input [`ADDR_WIDTH-1:0]	awaddr,
		input [3:0] 	awlen,
		input [2:0] 	awsize,
		input [1:0] 	awburst,
		input 			awvalid,
		output reg		awready,
		
		//WRITE DATA CHANNEL
		input [3:0] 		 	wid,
		input [`DATA_WIDTH-1:0] 	wdata,
		input [`STRB_WIDTH-1:0]	wstrb,
		input 					wlast,
		input 					wvalid,
		output reg				wready,

		//WRITE RESPONSE CHANNEL
		output reg [3:0]		bid,
		output reg [1:0]		bresp,
		output reg 				bvalid,
		input 					bready,

		//READ ADDRERSS CHANNEL
		input [3:0] 	arid,
		input [`ADDR_WIDTH-1:0]	araddr,
		input [3:0] 	arlen,
		input [2:0] 	arsize,
		input [1:0] 	arburst,
		input 			arvalid,
		output reg		arready,

		//READ DATA CHANNEL
		output reg [3:0] 			rid,
		output reg [`DATA_WIDTH-1:0] 	rdata,
		output reg [1:0] 			rresp,
		output reg 					rlast,
		output reg					rvalid,
		input 						rready

		//LOW POWER SIGNALS
	//	input 			csysreq,
	//	input 			csysack,
	//	input 			cactive

);
	//AXI MEMORY SUPPORTS BYTE ADDRESS MEMORY
	reg [7:0] mem [4095:0]; //asso [4095:0]


	//local variable indicates when to start WDATA phase
	reg wr_active;
	reg rd_active;
	
	reg [`ADDR_WIDTH-1:0] wr_addr;
	reg [`ADDR_WIDTH-1:0] ar_addr;
	reg [3:0] wr_len;
	reg [3:0] ar_len;
	reg [1:0] wr_burst;
	reg [1:0] ar_burst;
	reg [3:0] wr_id;
	reg [3:0] ar_id;
	reg [2:0] wr_size;
	reg [2:0] ar_size;

	integer i;
	integer strb,rd_strb; // it is a  4bit as per strb which value to store
	integer len;
	integer rd_count;


	//SLAVE WIRES FOR FIFO CONNECCTION
	wire fifo_wr_en;
	wire fifo_wr_sel;
	wire fifo_full;
	wire fifo_rd_en;
	wire fifo_empty;
	wire fifo_wr_error;//overflow condition
	wire fifo_rd_error;//underflow condition
	wire wr_start_fire;
	wire is_fifo_wr,is_fifo_rd;
	//wire fifo_rdata;
	

	assign fifo_wr_en =	(wr_active || (wvalid && wready)) && (wr_burst == 2'b00);

	assign fifo_rd_en =	(rd_active || (rvalid && rready)) && (ar_burst == 2'b00);

	//instantiate sync_fifo to DUT
	sync_fifo uut_sync_fifo(
   								.clk_i(aclk),
   								.rst_i(arstn),

   								.wr_en_i(fifo_wr_en),
   								.wdata_i(wdata),
   								.full_o(fifo_full),
   								.overflow_o(fifo_wr_error),
   								.rd_en_i(fifo_rd_en),
   								//.rdata_o(fifo_rdata),
   								.rdata_o(rdata),
   								.empty_o(fifo_empty),
   								.underflow_o(fifo_rd_error)
);


 	//WRITE AND READ TX
	always@(posedge aclk) begin
		if(arstn==0) begin
			for(i=0;i<4096;i=i+1) begin
				mem[i]=0;
			end
			awready=0;
			wready=0;
			bvalid=0;
			bid=0;
			bresp=0;
			wr_active=0;
			rd_count=0;
		end
		else begin
			//WRITE ADDRESS PHASE
			if(awvalid==1) begin
				awready=1;
				wr_active=1;
				wr_addr=awaddr; 
				wr_len=awlen;
				wr_size=awsize;
				wr_burst<=awburst;
				//rvalid <= !fifo_empty;
			end

			//WRITE DATA PHASE
			if(wr_active==1 && wvalid==1) begin
				wready = 1;
				wr_id = wid;
					if(fifo_wr_en == 0) begin	
						//check for each bit of wstrb
						for(strb=0;strb<`STRB_WIDTH;strb=strb+1) begin //0 to 3 
							if(wstrb[strb]) begin //wstrb is 4 bit if wstrb[0]==1 then store if 0 not store
								/*if 1 then store data into memory*/
							//	mem[wr_addr+strb]=wdata[(8*strb)+7:(8*strb)];
								mem[wr_addr+strb]=wdata[(8*strb)+:8];
							end
						end	
					//	end
						case(wr_burst)
						
						2'b00:begin
							wr_addr=wr_addr;
							$display("Burst type is FIXED");
						end
						2'b01:begin
							wr_addr=wr_addr+(1<<wr_size); //wr_addr=previos_addr + 2**awsize
							$display("Burst type is INCR");
						end
						2'b10:begin
							$display("Burst type is WRAP");

						end
						2'b11:begin
							$display("Burst type is RESERVED");
						end
						endcase
					end	
						if(wlast==1) begin
							bvalid=1;	
							wr_active=0;
						end
					//end	
			end			
			if(bvalid==1 && bready==1) begin
				bid=wr_id;
				bresp=2'b11;//DECERR
				bvalid=0;
			end
		end
	end	
	always@(posedge aclk) begin
		if(arstn == 0) begin
			rd_count=0;
		end
		//READ ADDRESS PHASE
			if(arvalid==1) begin
				arready=1;
				rd_active=1;//WRITE DATA PHASE IS PRESENT 
				//capture AW signals that are required for processing W AND B CHANNEL 	
				ar_id=arid; //needed for AXI4
				ar_addr=araddr; //issued by master to slave to store data internally
				ar_len=arlen;
				ar_size=arsize;
				ar_burst<=arburst;
				rd_count = 0;
			end


		//READ DATA CHANNEL
		if(rd_active && rready) begin
		    rvalid <= 1;
		   	if(fifo_rd_en == 0) begin	
						//check for each bit of wstrb
						for(rd_strb=0;rd_strb<`STRB_WIDTH;rd_strb=rd_strb+1) begin //0 to 3 
							//if(wstrb[strb]) begin //wstrb is 4 bit if wstrb[0]==1 then store if 0 not store
								/*if 1 then store data into memory*/
							//	mem[wr_addr+strb]=wdata[(8*strb)+7:(8*strb)];
								rdata[(8*rd_strb)+:8] = mem[ar_addr+rd_strb];
							//end
						end	
					//	end
						case(ar_burst)
						
						2'b00:begin
							ar_addr=ar_addr;
							$display("Burst type is FIXED");
						end
						2'b01:begin
							ar_addr=ar_addr+(1<<ar_size); //wr_addr=previos_addr + 2**awsize
							$display("Burst type is INCR");
						end
						2'b10:begin
							$display("Burst type is WRAP");

						end
						2'b11:begin
							$display("Burst type is RESERVED");
						end
						endcase
			end	
	//		else begin
	//			rdata=fifo_rdata;
	//		end
		    		
		    //-------------------------
		    // BEAT COUNT / LAST
		    //-------------------------
		    rid = ar_id;
			rlast = (rd_count == ar_len);
			rresp = 2'b00;
			if(rlast) begin
				rd_active =0 ;
			end
			rd_count =rd_count+1;

	    end
		else begin
			rlast=0;
		end
	end

endmodule



//| Channel | Signal  | Master | Slave  |
//| ------- | ------- | ------ | ------ |
//| AR      | ARVALID | Output | Input  |
//| AR      | ARREADY | Input  | Output |
//| AW      | AWVALID | Output | Input  |
//| AW      | AWREADY | Input  | Output |
//| W       | WVALID  | Output | Input  |
//| W       | WREADY  | Input  | Output |
//| B       | BVALID  | Input  | Output |
//| R       | RVALID  | Input  | Output |

// why iam getting 1 extra data at fifo_rdata
//rd_count: 0 1 2 3 4 5 6
//beats   : 1 2 3 4 5 6 7
//rlast asserted when rd_count == 6
//write data phase 
//valid is given by master and ready by slave
//in write respomse phase
//valid is given by slave and ready is by master
//read data phase
//valid is given by slave and ready is by master

