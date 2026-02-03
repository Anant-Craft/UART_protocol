/*

Input:  clk_3125 - 3125 KHz clock
        parity_type - even(0)/odd(1) parity type
        tx_start - signal to start the communication.
        data    - 8-bit data line to transmit

Output: tx      - UART Transmission Line
        tx_done - message transmitted flag


        Baudrate : 115200 bps
*/

// module declaration
module uart_tx(
    input clk_3125,
    input parity_type,      // 0 even, 1 odd
    input tx_start,
    input [7:0] data,
    output reg tx,
    output reg tx_done
);

localparam BAUD_MAX = 26; // 27 clocks

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
reg parity_bit;

initial begin
    tx = 1'b1;
    tx_done = 1'b0;
end

always @(posedge clk_3125) begin
    case(state)

    //--------------------------------------
    IDLE: begin
        tx <= 1'b1;
        tx_done <= 0;

        if(tx_start) begin
            data_buf <= data;
            parity_bit <= ^data;
            baud_cnt <= 0;
            state <= START;
        end
    end

    //--------------------------------------
    START: begin
        tx <= 0;

        if(baud_cnt == BAUD_MAX) begin
            baud_cnt <= 0;
            bit_idx <= 0;
            state <= DATA;
        end else
            baud_cnt <= baud_cnt + 1;
    end

    //--------------------------------------
    DATA: begin
        tx <= data_buf[0];                // LSB first

        if(baud_cnt == BAUD_MAX) begin
            baud_cnt <= 0;
            data_buf <= {1'b0, data_buf[7:1]}; // shift right

            if(bit_idx == 7)
                state <= PARITY;
            else
                bit_idx <= bit_idx + 1;
        end else
            baud_cnt <= baud_cnt + 1;
    end

    //--------------------------------------
    PARITY: begin
        tx <= parity_type ? ~parity_bit : parity_bit;

        if(baud_cnt == BAUD_MAX) begin
            baud_cnt <= 0;
            state <= STOP;
        end else
            baud_cnt <= baud_cnt + 1;
    end

    //--------------------------------------
    STOP: begin
        tx <= 1;

        if(baud_cnt == BAUD_MAX) begin
            tx_done <= 1;
            state <= IDLE;
        end else
            baud_cnt <= baud_cnt + 1;
    end

    endcase
end

endmodule
