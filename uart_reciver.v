module uart_rx(
    input clk_3125,
    input rx,
    output reg [7:0] rx_msg,
    output reg rx_parity,
    output reg parity_error,
    output reg rx_complete
);

localparam BAUD_MAX  = 26;   // full bit
localparam HALF_BAUD = 13;   // mid sample

localparam [2:0]
    IDLE   = 0,
    START  = 1,
    DATA   = 2,
    PARITY = 3,
    STOP   = 4;

reg [2:0] state = IDLE;
reg [4:0] baud_cnt = 0;
reg [2:0] bit_idx = 0;
reg [7:0] data_buf;
reg parity_sample;

always @(posedge clk_3125) begin

    case(state)

    //--------------------------------------
    IDLE: begin
        rx_complete <= 0;

        if(!rx) begin               // detect start
            baud_cnt <= 0;
            state <= START;
        end
    end

    //--------------------------------------
    // wait HALF bit to sample center
    START: begin
        if(baud_cnt == HALF_BAUD) begin
            baud_cnt <= 0;
            bit_idx <= 0;
            state <= DATA;
        end else
            baud_cnt <= baud_cnt + 1;
    end

    //--------------------------------------
    DATA: begin
        if(baud_cnt == BAUD_MAX) begin
            baud_cnt <= 0;

            data_buf <= {rx, data_buf[7:1]}; // LSB first shift

            if(bit_idx == 7)
                state <= PARITY;
            else
                bit_idx <= bit_idx + 1;
        end else
            baud_cnt <= baud_cnt + 1;
    end

    //--------------------------------------
    PARITY: begin
        if(baud_cnt == BAUD_MAX) begin
            parity_sample <= rx;    // capture received parity
            baud_cnt <= 0;
            state <= STOP;
        end else
            baud_cnt <= baud_cnt + 1;
    end

    //--------------------------------------
    STOP: begin
        if(baud_cnt == BAUD_MAX) begin
            baud_cnt <= 0;

            rx_msg <= data_buf;
            rx_parity <= parity_sample;
            parity_error <= (parity_sample != ^data_buf);

            rx_complete <= 1;
            state <= IDLE;
        end else
            baud_cnt <= baud_cnt + 1;
    end

    endcase
end

endmodule
