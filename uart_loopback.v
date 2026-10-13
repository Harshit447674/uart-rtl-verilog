
module uart_loopback #(
    parameter CLKS_PER_BIT = 217
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       tx_start,
    input  wire [7:0] tx_data,

    output wire       tx,
    output wire       tx_busy,
    output wire       tx_done,

    output wire [7:0] rx_data,
    output wire       rx_valid,
    output wire       rx_error
);

    wire baud_tick;

    // Generate the baud-rate tick.
    baud_gen #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) baud_generator (
        .clk(clk),
        .rst(rst),
        .baud_tick(baud_tick)
    );

    // Transmitter uses the generated tick.
    uart_tx transmitter (
        .clk(clk),
        .rst(rst),
        .baud_tick(baud_tick),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .tx_busy(tx_busy),
        .tx_done(tx_done)
    );

    // Receiver samples the serial output.
    uart_rx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) receiver (
        .clk(clk),
        .rst(rst),
        .rx(tx),
        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .rx_error(rx_error)
    );

endmodule

