module testbench_simulation ();

    /* control signals */
    reg rst_n, clk;
    reg ps2_clk, ps2_data;

    wire [6:0] byte_h_digit_h;
    wire [6:0] byte_h_digit_l;
    wire [6:0] byte_l_digit_h;
    wire [6:0] byte_l_digit_l;

    /* DUT (design under test) instantiation */
    ps2 dut (
        .clk           (clk           ),
        .rst_n         (rst_n         ),
        .ps2_clk       (ps2_clk       ),
        .ps2_data      (ps2_data      ),
        
        .byte_h_digit_h(byte_h_digit_h),
        .byte_h_digit_l(byte_h_digit_l),
        .byte_l_digit_h(byte_l_digit_h),
        .byte_l_digit_l(byte_l_digit_l)
    );

    /* constants */
    localparam A_KEY_MAKE_CODE      = 8'h1C     ;
    localparam A_KEY_BREAK_CODE     = 16'hF01C  ;
    localparam RCTRL_KEY_MAKE_CODE  = 16'hE014  ;
    localparam RCTRL_KEY_BREAK_CODE = 24'hE0F014;

    localparam SEND_START_BIT  = 0 ;
    localparam SEND_PARITY_BIT = 9 ;
    localparam SEND_STOP_BIT   = 10;

    localparam START_BIT_VAL      = 1'b0;
    localparam STOP_BIT_VAL       = 1'b1;
    localparam PACKAGE_LENGTH = 11  ;                                   //11 bits (START bit, SCAN_CODE_BYTE[0:7], PARITY bit, STOP bit)

    localparam DELAY = 50;                                              //for timing control

    localparam COUNTER_INIT_VALUE = 4'b0;

    /* variables */
    reg     bit_ready_to_send = 1'b1;                                   //is there a bit to send to the ps2 module
    integer i                       ;                                   //the loop counter

    /* rst_n & clk */
    initial begin
        clk = 1'b0;
        rst_n = 1'b0;                                                   //reset the module
        #DELAY rst_n = 1'b1;                                            //start the module

        forever #1 clk = ~clk;                                          //necessary to simulate fast FPGA clock
    end

    /* keyboard simulation logic */
    initial begin
        /* no keys pressed */
        ps2_clk = 1'b1;
        ps2_data = 1'b1;
        #DELAY;                                                         //wait for rst_n == 1

        /* 1. send: (make 1C) x 2, (break F0 1C) x 1 */
        send_package(COUNTER_INIT_VALUE, A_KEY_MAKE_CODE);              //1C (key pressed)
        send_package(COUNTER_INIT_VALUE, A_KEY_MAKE_CODE);              //1C

        send_package(COUNTER_INIT_VALUE, A_KEY_BREAK_CODE[15:8]);       //F0 (key released)
        send_package(COUNTER_INIT_VALUE, A_KEY_BREAK_CODE[7:0]);        //1C

        /* 2. send: (make E0 14) x 2, (break E0 F0 14) x 1 */
        send_package(COUNTER_INIT_VALUE, RCTRL_KEY_MAKE_CODE[15:8]);    //E0 (key pressed)
        send_package(COUNTER_INIT_VALUE, RCTRL_KEY_MAKE_CODE[7:0]);     //14

        send_package(COUNTER_INIT_VALUE, RCTRL_KEY_MAKE_CODE[15:8]);    //E0
        send_package(COUNTER_INIT_VALUE, RCTRL_KEY_MAKE_CODE[7:0]);     //14

        send_package(COUNTER_INIT_VALUE, RCTRL_KEY_BREAK_CODE[23:16]);  //E0 (key released)
        send_package(COUNTER_INIT_VALUE, RCTRL_KEY_BREAK_CODE[15:8]);   //F0
        send_package(COUNTER_INIT_VALUE, RCTRL_KEY_BREAK_CODE[7:0]);    //14

        /* no keys pressed */
        #DELAY ps2_clk = 1'b1;                                          //necessary for the STOP bit of the previous byte to be accepted by the ps2 module (debouncing)

        #DELAY ps2_data = 1;
        #5 ps2_clk = 1;
        #DELAY ps2_clk = 1;

        #DELAY ps2_data = 1;
        #5 ps2_clk = 1;
        #DELAY ps2_clk = 1;

        $finish;
    end

    always @(posedge clk) begin
        $strobe(
            "time = %3d, ps2_clk = %b, ps2_data = %b, out = %h",
            $time, ps2_clk, ps2_data, { hex_digit(byte_h_digit_h), hex_digit(byte_h_digit_l), hex_digit(byte_l_digit_h), hex_digit(byte_l_digit_l) }
        );
    end

    /* function to get a hexadecimal digit from a 7SEG display input value */
    function reg [3:0] hex_digit(input reg [6:0] value);
        case (value)
            ~7'h3F: hex_digit = 4'b0000;
            ~7'h06: hex_digit = 4'b0001;
            ~7'h5B: hex_digit = 4'b0010;
            ~7'h4F: hex_digit = 4'b0011;
            ~7'h66: hex_digit = 4'b0100;
            ~7'h6D: hex_digit = 4'b0101;
            ~7'h7D: hex_digit = 4'b0110;
            ~7'h07: hex_digit = 4'b0111;
            ~7'h7F: hex_digit = 4'b1000;
            ~7'h6F: hex_digit = 4'b1001;
            ~7'h77: hex_digit = 4'b1010;
            ~7'h7C: hex_digit = 4'b1011;
            ~7'h39: hex_digit = 4'b1100;
            ~7'h5E: hex_digit = 4'b1101;
            ~7'h79: hex_digit = 4'b1110;
            ~7'h71: hex_digit = 4'b1111;
        endcase
    endfunction

    /* task to send an 11 bit package to the ps2 module */
    task send_package (input reg [3:0] ones_counter, input reg [7:0] current_byte);
        for (i = 0; i < PACKAGE_LENGTH; i = i + 1) begin
            /* send the ps2_data bit */
            if (bit_ready_to_send) begin
                #DELAY;                                                                 //necessary to simulate slow PS2 keyboard clock

                case (i)
                    SEND_START_BIT  : ps2_data = START_BIT_VAL;                         //send the START bit
                    SEND_PARITY_BIT : ps2_data = (ones_counter % 2 == 0) ? 1'b1 : 1'b0; //send the PARITY bit (odd parity)
                    SEND_STOP_BIT   : ps2_data = STOP_BIT_VAL;                          //send the STOP bit

                    default : begin                                                     //SCAN_CODE_BYTE[0:7]
                        ps2_data = current_byte[0];
                        current_byte = current_byte >> 1;

                        if (ps2_data == 1'b1) ones_counter = ones_counter + 1;
                    end
                endcase
            end

            /* the ps2_clk falling edge logic implementation */
            if (bit_ready_to_send) begin                                                //set ps2_clk to 0 when the ps2_data bit is to be sent
                #5 ps2_clk = 1'b0;
                bit_ready_to_send = 1'b0;
            end else begin
                #DELAY ps2_clk = 1'b1;                                                  //necessary for the previous ps2_data bit to be accepted by the ps2 module (debouncing)

                i = i - 1;
                bit_ready_to_send = 1'b1;                                               //prepare to send the next ps2_data bit on the falling edge of the ps2_clk signal
            end
        end
    endtask

endmodule
