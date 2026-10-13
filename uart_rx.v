
module uart_rx #(
    parameter CLKS_PER_BIT = 217
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       rx,

    output reg  [7:0] rx_data,
    output reg        rx_valid,
    output reg        rx_error
);

    localparam IDLE  = 3'd0;
    localparam START = 3'd1;
    localparam DATA  = 3'd2;
    localparam STOP  = 3'd3;

    reg [2:0] state;
    reg [7:0] rx_shift;
    reg [2:0] bit_idx;
    reg [15:0] clk_count;

    // Synchronize the asynchronous RX input to clk.
    reg rx_meta;
    reg rx_sync;

    always @(posedge clk) begin
        if (rst) begin
            rx_meta <= 1'b1;
            rx_sync <= 1'b1;
        end
        else begin
            rx_meta <= rx;
            rx_sync <= rx_meta;
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            state     <= IDLE;
            rx_shift  <= 8'b0;
            rx_data   <= 8'b0;
            bit_idx   <= 3'b0;
            clk_count <= 16'b0;
            rx_valid  <= 1'b0;
            rx_error  <= 1'b0;
        end
        else begin
            rx_valid <= 1'b0;
            rx_error <= 1'b0;

            case (state)
                IDLE: begin
                    clk_count <= 0;
                    bit_idx   <= 0;

                    if (rx_sync == 1'b0) begin
                        state     <= START;
                        clk_count <= 0;
                    end
                end

                START: begin
                    if (clk_count == (CLKS_PER_BIT/2 - 1)) begin
                        if (rx_sync == 1'b0) begin
                            state     <= DATA;
                            clk_count <= 0;
                            bit_idx   <= 0;
                        end
                        else begin
                            state <= IDLE;
                        end
                    end
                    else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                DATA: begin
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 0;
                        rx_shift[bit_idx] <= rx_sync;

                        if (bit_idx == 7) begin
                            state <= STOP;
                        end
                        else begin
                            bit_idx <= bit_idx + 1'b1;
                        end
                    end
                    else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                STOP: begin
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 0;
                        state <= IDLE;

                        if (rx_sync == 1'b1) begin
                            rx_data  <= rx_shift;
                            rx_valid <= 1'b1;
                        end
                        else begin
                            rx_error <= 1'b1;
                        end
                    end
                    else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                default: begin
                    state     <= IDLE;
                    clk_count <= 0;
                    rx_valid  <= 1'b0;
                    rx_error  <= 1'b0;
                end
            endcase
        end
    end

endmodule

