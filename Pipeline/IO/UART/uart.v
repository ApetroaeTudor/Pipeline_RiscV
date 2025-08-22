module uart #(
    parameter DELAY_FRAMES = 234
)(

    input i_clk,
    input i_rst,
    input i_send_button, // active low to send data in memory

    output [5:0] o_leds,
    input uart_rx,
    output uart_tx
);

    // RX
    
    localparam HALF_DELAY = DELAY_FRAMES/2;

    reg [2:0] r_rx_cs;
    reg [2:0] r_rx_bit_idx;
    reg [7:0] r_rx_delay_timer;
    reg [7:0] r_data_in;
    reg r_byte_ready;

    localparam RX_IDLE = 3'b000;
    localparam RX_START = 3'b001;
    localparam RX_READY_WAIT = 3'b010;
    localparam RX_READ = 3'b011;
    localparam RX_FINISHED = 3'b100;

    reg [5:0] r_leds = 6'b1111_11;
    assign o_leds = r_leds;

    always@(posedge i_clk)
    begin
        if(!i_rst)
        begin
            r_rx_cs<=0;
            r_rx_bit_idx<=0;
            r_rx_delay_timer<=0;
            r_data_in<=8'b0;
            r_byte_ready<=0;
        end
        else
        begin

            case(r_rx_cs)
            
            RX_IDLE: begin
                if(uart_rx == 0)
                begin
                    r_byte_ready<=0;
                    r_rx_delay_timer<=8'b0000_0001;
                    r_rx_bit_idx<=0;
                    r_rx_cs<=RX_START;
                end
            end

            RX_START: begin
                if((r_rx_delay_timer) == HALF_DELAY)
                begin
                    r_rx_cs<=RX_READY_WAIT;
                    r_rx_delay_timer<=8'b0000_0001;
                end
                else
                begin
                    r_rx_delay_timer<=r_rx_delay_timer+8'b0000_0001;
                end
            end

            RX_READY_WAIT: begin 
                r_rx_delay_timer<=r_rx_delay_timer+8'b0000_0001;
                if((r_rx_delay_timer+1) == DELAY_FRAMES )
                begin
                    r_rx_cs<=RX_READ;
                end
            end

            RX_READ: begin
                r_rx_delay_timer<=8'b0000_0001;
                r_data_in<={uart_rx,r_data_in[7:1]};
                r_rx_bit_idx<=r_rx_bit_idx+3'b001;

                if(r_rx_bit_idx==3'b111) r_rx_cs<=RX_FINISHED;
                else r_rx_cs<=RX_READY_WAIT;
            end

            RX_FINISHED: begin
                r_rx_delay_timer<=r_rx_delay_timer+8'b0000_0001;

                if( (r_rx_delay_timer+1) == DELAY_FRAMES)
                begin
                    r_rx_cs<=RX_IDLE;
                    r_rx_delay_timer<=0;
                    r_byte_ready<=1'b1;
                end
            end
            endcase
        end
    end

    always@(posedge i_clk)
    begin
        if(r_byte_ready)
        begin
            r_leds<=~r_data_in[5:0];
        end
    end


    // TX

    reg [2:0] r_tx_cs;
    reg [2:0] r_tx_bit_idx;
    reg [2:0] r_tx_byte_idx;
    reg [24:0] r_tx_delay_timer;
    reg [7:0] r_tx_data_out;

    reg [7:0] r_tx_inner_mem [7:0];

    reg r_tx;
    assign uart_tx = r_tx;

    localparam TX_IDLE = 3'b000;
    localparam TX_START = 3'b001;
    localparam TX_WRITE = 3'b010;
    localparam TX_FINISHED = 3'b011; // stop bit
    localparam TX_DEBOUNCE = 3'b100; // wait 1 sec before registering the new button press in order to eliminate misclicks

    always@(posedge i_clk)
    begin
        if(!i_rst)
        begin
            r_tx_cs<=0;
            r_tx_bit_idx<=0;
            r_tx_byte_idx<=0;
            r_tx_delay_timer<=0;
            r_tx_data_out<=0;
            r_tx_inner_mem[0] = "h";
            r_tx_inner_mem[1] = "e";
            r_tx_inner_mem[2] = "l";
            r_tx_inner_mem[3] = "l";
            r_tx_inner_mem[4] = "o";
            r_tx_inner_mem[5] = "!";
            r_tx_inner_mem[6] = "!";
            r_tx_inner_mem[7] = " ";
        end
        else
        begin
            case(r_tx_cs)
            
            TX_IDLE: begin
                if(i_send_button == 1'b0)
                begin
                    r_tx_cs<=TX_START;
                    r_tx_delay_timer<=0;
                    r_tx<=1'b0;
                    r_tx_byte_idx<=0;
                end
                else r_tx<=1'b1;
            end

            TX_START: begin
                r_tx<=1'b0;

                if ((r_tx_delay_timer +1) == DELAY_FRAMES)
                begin
                    r_tx_cs<=TX_WRITE;
                    r_tx_data_out<=r_tx_inner_mem[r_tx_byte_idx];
                    r_tx_bit_idx<=0;            
                    r_tx_delay_timer<=24'd0;     
                end
                else r_tx_delay_timer<=r_tx_delay_timer+24'd1;
            end

            TX_WRITE: begin
                r_tx <= r_tx_data_out[r_tx_bit_idx];

                if((r_tx_delay_timer+1)==DELAY_FRAMES)
                begin
                    r_tx_delay_timer=24'd0;

                    if(r_tx_bit_idx==3'b111)
                    begin
                        r_tx_cs<=TX_FINISHED;
                    end
                    else begin
                        r_tx_bit_idx<=r_tx_bit_idx+3'b001;
                        r_tx_cs<=TX_WRITE;
                    end
                end
                else r_tx_delay_timer<=r_tx_delay_timer+24'd1;
            end

            TX_FINISHED: begin 
                r_tx<=1;

                if((r_tx_delay_timer+1) == DELAY_FRAMES)
                begin
                    r_tx_delay_timer<=24'd0;

                    if(r_tx_byte_idx == 3'd7) // mem len - 1 = 7
                    begin
                        r_tx_cs<=TX_DEBOUNCE;
                    end
                    else
                    begin
                        r_tx_byte_idx<=r_tx_byte_idx+3'd1;
                        r_tx_cs<=TX_START;
                    end
                end
                else r_tx_delay_timer<=r_tx_delay_timer + 24'd1;
            end

            TX_DEBOUNCE: begin
                if(r_tx_delay_timer == 24'b11111111_11111111_11111111)
                begin
                    if(i_send_button == 1'b1)
                    begin
                        r_tx_delay_timer<=24'd0;
                        r_tx_cs<=TX_IDLE;
                    end
                end
                else r_tx_delay_timer<=r_tx_delay_timer+24'd1;
            end
            endcase
        end
    end



endmodule