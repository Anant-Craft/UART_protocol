module uart_top(input clk);

wire tx, busy, done;
wire [7:0] rx_data;

reg start = 0;
reg [7:0] tx_data;

uart_tx TX (
    .clk(clk),
    .start(start),
    .data(tx_data),
    .tx(tx),
    .busy(busy)
);

uart_rx RX (
    .clk(clk),
    .rx(tx),
    .data(rx_data),
    .done(done)
);

reg [7:0] msg [0:4];
integer i;

initial begin
    msg[0] = "H";
    msg[1] = "E";
    msg[2] = "L";
    msg[3] = "L";
    msg[4] = "O";

    #50;

    for(i=0;i<5;i=i+1)
        send(msg[i]);

    #500 $finish;
end

task send(input [7:0] d);
begin
    @(negedge clk);
    tx_data = d;
    start = 1;

    @(negedge clk);
    start = 0;

    wait(busy==0);
    wait(done==1);

    $display("RX = %c (%h)", rx_data, rx_data);
end
endtask

endmodule
