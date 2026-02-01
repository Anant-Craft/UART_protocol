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
    input parity_type,tx_start,
    input [7:0] data,
    output reg tx, tx_done
);

initial begin
    tx = 1'b1;
    tx_done = 1'b0;
end

 localparam [2:0]
        IDLE   = 3'b000,
        START  = 3'b001,
        DATA   = 3'b010,
        PARITY = 3'b011,
        STOP   = 3'b100;

    reg [2:0] state = IDLE;
    reg [7:0] data_buf;
    reg [2:0] bit_idx;
    reg [4:0] baud_cnt;      // counts 0–27 for each bit time
    reg       parity_bit;

    always @(posedge clk_3125) begin
        case(state)
            //--------------------------------------
            IDLE: begin
                tx <= 1'b1;
                tx_done <= 1'b0;
                baud_cnt <= 0;
                bit_idx <= 0;
                if (tx_start) begin
                    data_buf = data;
                    parity_bit <= ^data; // XOR reduction operator
						  tx <= 1'b0;
                    state <= START;
                end
            end

            //--------------------------------------
            START: begin
                tx <= 1'b0; // start bit
                if (baud_cnt == 25) begin
                    baud_cnt <= 0;
                    state <= DATA;
                end else
                    baud_cnt <= baud_cnt + 1;
            end

            //--------------------------------------
            DATA: begin
                tx <= data_buf[7];
                if (baud_cnt == 26) begin
                    baud_cnt <= 0;
                    data_buf <= {data_buf[6:0],1'b0}; // shift left
                    if (bit_idx == 7)
                        state <= PARITY;
                    else
                        bit_idx <= bit_idx + 1;
                end else
                    baud_cnt <= baud_cnt + 1;
            end

            //--------------------------------------
            PARITY: begin
                tx <= (parity_type) ? ~parity_bit : parity_bit;
                if (baud_cnt == 26) begin
                    baud_cnt <= 0;
                    state <= STOP;
                end else
                    baud_cnt <= baud_cnt + 1;
            end

            //--------------------------------------
            STOP: begin
                tx <= 1'b1; // stop bit
                if (baud_cnt == 26) begin
                    baud_cnt <= 0;
                    tx_done <= 1'b1;
                    state <= (tx_start) ? START : IDLE;
                end else
                    baud_cnt <= baud_cnt + 1;
            end

            default: state <= IDLE;
        endcase
    end
endmodule