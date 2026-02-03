module uart_rx(
    input clk_3125,
    input rx,
    output reg [7:0] rx_msg,
    output reg rx_parity,
    output reg rx_complete
);

initial begin
    rx_msg = 8'b0;
    rx_parity = 1'b0;
    rx_complete = 1'b0;
end


localparam [2:0] IDLE = 3'b000, START = 3'b001, DATA = 3'b010, PARITY = 3'b011, STOP = 3'b100;

reg [2:0] state = IDLE;
reg [4:0] baud_cnt = 0;
reg [2:0] bit_idx = 0;
reg [7:0] data_buf = 8'd0;
reg       parity_bit = 1'b0;
reg       synced = 1'b0;   // <--- new flag

always @(posedge clk_3125) begin
    // skip first clock to align with TB
    if (!synced) begin
        synced <= 1'b1;
        state <= IDLE;
        rx_complete <= 1'b0;
        baud_cnt <= 0;
        bit_idx <= 0;
    end
    else begin
        case(state)
            //--------------------------------------
            IDLE: begin
                rx_complete <= 1'b0;
                baud_cnt <= 0;
                bit_idx <= 0;

                if (!rx) // detect start bit
                    state <= START;
            end

            //--------------------------------------
            START: begin
                if (baud_cnt == 26) begin
                    baud_cnt <= 0;
                    state <= DATA;
                end else
                    baud_cnt <= baud_cnt + 1;
            end

            //--------------------------------------
            DATA: begin
                if (baud_cnt == 26) begin
                    baud_cnt <= 0;
                    module uart_rx(
    input clk_3125,
    input rx,
    output reg [7:0] rx_msg,
    output reg rx_parity,
    output reg rx_complete
);

initial begin
    rx_msg = 8'b0;
    rx_parity = 1'b0;
    rx_complete = 1'b0;
end


localparam [2:0] IDLE = 3'b000, START = 3'b001, DATA = 3'b010, PARITY = 3'b011, STOP = 3'b100;

reg [2:0] state = IDLE;
reg [4:0] baud_cnt = 0;
reg [2:0] bit_idx = 0;
reg [7:0] data_buf = 8'd0;
reg       parity_bit = 1'b0;
reg       synced = 1'b0;   // <--- new flag

always @(posedge clk_3125) begin
    // skip first clock to align with TB
    if (!synced) begin
        synced <= 1'b1;
        state <= IDLE;
        rx_complete <= 1'b0;
        baud_cnt <= 0;
        bit_idx <= 0;
    end
    else begin
        case(state)
            //--------------------------------------
            IDLE: begin
                rx_complete <= 1'b0;
                baud_cnt <= 0;
                bit_idx <= 0;

                if (!rx) // detect start bit
                    state <= START;
            end

            //--------------------------------------
            START: begin
                if (baud_cnt == 26) begin
                    baud_cnt <= 0;
                    state <= DATA;
                end else
                    baud_cnt <= baud_cnt + 1;
            end

            //--------------------------------------
            DATA: begin
                if (baud_cnt == 26) begin
                    baud_cnt <= 0;
                    module uart_rx(
    input clk_3125,
    input rx,
    output reg [7:0] rx_msg,
    output reg rx_parity,
    output reg rx_complete
);

initial begin
    rx_msg = 8'b0;
    rx_parity = 1'b0;
    rx_complete = 1'b0;
end


localparam [2:0] IDLE = 3'b000, START = 3'b001, DATA = 3'b010, PARITY = 3'b011, STOP = 3'b100;

reg [2:0] state = IDLE;
reg [4:0] baud_cnt = 0;
reg [2:0] bit_idx = 0;
reg [7:0] data_buf = 8'd0;
reg       parity_bit = 1'b0;
reg       synced = 1'b0;   // <--- new flag

always @(posedge clk_3125) begin
    // skip first clock to align with TB
    if (!synced) begin
        synced <= 1'b1;
        state <= IDLE;
        rx_complete <= 1'b0;
        baud_cnt <= 0;
        bit_idx <= 0;
    end
    else begin
        case(state)
            //--------------------------------------
            IDLE: begin
                rx_complete <= 1'b0;
                baud_cnt <= 0;
                bit_idx <= 0;

                if (!rx) // detect start bit
                    state <= START;
            end

            //--------------------------------------
            START: begin
                if (baud_cnt == 26) begin
                    baud_cnt <= 0;
                    state <= DATA;
                end else
                    baud_cnt <= baud_cnt + 1;
            end

            //--------------------------------------
            DATA: begin
                if (baud_cnt == 26) begin
                    baud_cnt <= 0;
                    data_buf <= {data_buf[6:0], rx}; // shift left
                    if (bit_idx == 7)
                        state <= PARITY;
                    else
                        bit_idx <= bit_idx + 1;
                end else
                    baud_cnt <= baud_cnt + 1;
            end

            //--------------------------------------
            PARITY: begin
                parity_bit <= ^data_buf;
                if (baud_cnt == 26) begin
                    baud_cnt <= 0;
                    state <= STOP;
                end else
                    baud_cnt <= baud_cnt + 1;
            end

            //--------------------------------------
            STOP: begin
                if (baud_cnt == 26) begin
                    baud_cnt <= 0;
                    rx_complete <= (data_buf != rx_msg) ? 1'b1 : 1'b0;
                    rx_parity <= parity_bit;
                    rx_msg <= data_buf;
                    state <= IDLE;
                end else
                    baud_cnt <= baud_cnt + 1;
            end

            default: state <= IDLE;
        endcase
    end
end


endmodule

; // shift left
                    if (bit_idx == 7)
                        state <= PARITY;
                    else
                        bit_idx <= bit_idx + 1;
                end else
                    baud_cnt <= baud_cnt + 1;
            end

            //--------------------------------------
            PARITY: begin
                parity_bit <= ^data_buf;
                if (baud_cnt == 26) begin
                    baud_cnt <= 0;
                    state <= STOP;
                end else
                    baud_cnt <= baud_cnt + 1;
            end

            //--------------------------------------
            STOP: begin
                if (baud_cnt == 26) begin
                    baud_cnt <= 0;
                    rx_complete <= (data_buf != rx_msg) ? 1'b1 : 1'b0;
                    rx_parity <= parity_bit;
                    rx_msg <= data_buf;
                    state <= IDLE;
                end else
                    baud_cnt <= baud_cnt + 1;
            end

            default: state <= IDLE;
        endcase
    end
end


endmodule

; // shift left
                    if (bit_idx == 7)
                        state <= PARITY;
                    else
                        bit_idx <= bit_idx + 1;
                end else
                    baud_cnt <= baud_cnt + 1;
            end

            //--------------------------------------
            PARITY: begin
                parity_bit <= ^data_buf;
                if (baud_cnt == 26) begin
                    baud_cnt <= 0;
                    state <= STOP;
                end else
                    baud_cnt <= baud_cnt + 1;
            end

            //--------------------------------------
            STOP: begin
                if (baud_cnt == 26) begin
                    baud_cnt <= 0;
                    rx_complete <= (data_buf != rx_msg) ? 1'b1 : 1'b0;
                    rx_parity <= parity_bit;
                    rx_msg <= data_buf;
                    state <= IDLE;
                end else
                    baud_cnt <= baud_cnt + 1;
            end

            default: state <= IDLE;
        endcase
    end
end


endmodule

