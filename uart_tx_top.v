
module uart_tx_top #(
    parameter CLKS_PER_BIT = 217
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       tx_start,
    input  wire [7:0] tx_data,
    output wire       tx,
    output wire       tx_busy,
    output wire       tx_done
);

    wire baud_tick;

    baud_gen #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) baud_inst (
        .clk(clk),
        .rst(rst),
        .baud_tick(baud_tick)
    );

    uart_tx tx_inst (
        .clk(clk),
        .rst(rst),
        .baud_tick(baud_tick),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .tx_busy(tx_busy),
        .tx_done(tx_done)
    );

endmodule

