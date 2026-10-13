
module uart_tx (
    input  wire       clk,
    input  wire       rst,
    input  wire       baud_tick,
    input  wire       tx_start,
    input  wire [7:0] tx_data,
    output reg        tx,
    output reg        tx_busy,
    output reg        tx_done
);

    localparam IDLE  = 3'd0;
    localparam START = 3'd1;
    localparam DATA  = 3'd2;
    localparam STOP  = 3'd3;
    localparam DONE  = 3'd4;
    reg [2:0] state;
    reg [7:0] tx_shift;
    reg [2:0] bit_idx;

    always @(posedge clk) begin
        if (rst) begin
            state    <= IDLE;
            tx       <= 1'b1;
            tx_busy  <= 1'b0;
            tx_done  <= 1'b0;
            tx_shift <= 8'b0;
            bit_idx  <= 3'b0;
        end
	else begin
            tx_done <= 1'b0;

            case (state)
                IDLE: begin
                    tx      <= 1'b1;
                    tx_busy <= 1'b0;

                    if (baud_tick && tx_start) begin
                        tx_shift <= tx_data;
                        bit_idx  <= 3'd0;
                        tx       <= 1'b0;
                        tx_busy  <= 1'b1;
                        state    <= START;
                    end
                end

                START: begin
                    if (baud_tick) begin
                        tx      <= tx_shift[0];
                        tx_shift <= tx_shift >> 1;
                        bit_idx <= 3'd1;
                        state   <= DATA;
                    end
                end

                DATA: begin
                    if (baud_tick) begin
                        if (bit_idx < 7) begin
                            tx       <= tx_shift[0];
                            tx_shift <= tx_shift >> 1;
                            bit_idx  <= bit_idx + 1'b1;
                        end
                        else begin
                            tx    <= tx_shift[0];
                            state <= STOP;
                        end
                    end
                end

                STOP: begin
                    if (baud_tick) begin
                        tx      <= 1'b1;
                        state   <= DONE;
                    end
                end
		DONE: begin
			if(baud_tick) begin
				tx_done<=1'b1;
				tx_busy<=1'b0;
				state<=IDLE;
			end
		end

                default: begin
                    state   <= IDLE;
                    tx      <= 1'b1;
                    tx_busy <= 1'b0;
                end
            endcase
        end
end

endmodule

