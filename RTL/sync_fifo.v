`define WIDTH 32
`define FIFO_SIZE 32
`define PTR_WIDTH $clog2(`FIFO_SIZE)

module sync_fifo(
    input clk_i,
    input rst_i,

    input wr_en_i,
    input [`WIDTH-1:0] wdata_i,
    output reg full_o,
    output reg overflow_o,

    input rd_en_i,
    output reg [`WIDTH-1:0] rdata_o,
    output reg empty_o,
    output reg underflow_o
);

reg [`WIDTH-1:0] fifo [`FIFO_SIZE-1:0];
reg [`PTR_WIDTH-1:0] wr_ptr, rd_ptr;
reg wr_toggle_f, rd_toggle_f;

integer i;

// ---- Read pipeline register ----
reg [`WIDTH-1:0] rdata_int;
reg rd_en_d;

always @(posedge clk_i) begin
    if (rst_i==0) begin
        wr_ptr <= 0;
        rd_ptr <= 0;
        wr_toggle_f <= 0;
        rd_toggle_f <= 0;

        empty_o <= 1;
        full_o  <= 0;
        overflow_o <= 0;
        underflow_o <= 0;
        rdata_o <= 0;

		rdata_int <= 0;
        rd_en_d <= 0;
		

        for(i=0;i<`FIFO_SIZE;i=i+1)
            fifo[i] <= 0;
    end
    else begin
        overflow_o <= 0;
        underflow_o <= 0;

        //---------------- WRITE ----------------
        if (wr_en_i && !full_o) begin
            fifo[wr_ptr] <= wdata_i;

            if (wr_ptr == `FIFO_SIZE-1) begin
                wr_ptr <= 0;
                wr_toggle_f <= ~wr_toggle_f;
            end
            else
                wr_ptr <= wr_ptr + 1;
        end
        else if (wr_en_i && full_o)
            overflow_o <= 1;

        //---------------- READ -----------------

		rd_en_d <= rd_en_i && !empty_o;	
			
        if (rd_en_i && !empty_o) begin
            rdata_int <= fifo[rd_ptr];

            if (rd_ptr == `FIFO_SIZE-1) begin
                rd_ptr <= 0;
                rd_toggle_f <= ~rd_toggle_f;
            end
            else
                rd_ptr <= rd_ptr + 1;
        end
        else if (rd_en_i && empty_o)
            underflow_o <= 1;

		// ---------------- READ STAGE 2 (OUTPUT REGISTER) ----------------
        if (rd_en_d)
            rdata_o <= rdata_int;	

        empty_o <= (wr_ptr == rd_ptr) &&
                   (wr_toggle_f == rd_toggle_f);

        full_o  <= (wr_ptr == rd_ptr) &&
                   (wr_toggle_f != rd_toggle_f);
    end
end

endmodule

