`include "uvm_macros.svh"
import uvm_pkg::*;

localparam DELAY = 50;					//for timing control (necessary to simulate slow PS2 keyboard clock)

/* stores the data from the ps2 module ports */
class ps2_item extends uvm_sequence_item;
	/* class fields & registration macro */
	bit       ps2_clk       ;			//PS2 keyboard clock signal
	bit       ps2_data      ;			//PS2 keyboard data signal
	bit [6:0] byte_h_digit_h;
	bit [6:0] byte_h_digit_l;
	bit [6:0] byte_l_digit_h;
	bit [6:0] byte_l_digit_l;

	`uvm_object_utils(ps2_item)

	/* class constructor */
	function new(string name = "ps2_item");		//parameter 'name': the name of this class
		super.new(name);
	endfunction

	/* virtual function to print the values of the class fields */
	virtual function string manual_item_print();
		return $sformatf(
			"time = %3d, ps2_clk = %1b ps2_data = %1b",
			$time, ps2_clk, ps2_data
		);
	endfunction
endclass

/* generates a set of data to send to the driver class */
class generator extends uvm_sequence;
	/* registration macro & constructor */
	`uvm_object_utils(generator)

	function new(string name = "generator");
		super.new(name);
	endfunction

	/* task body() */
	localparam NUM_OF_ITERATIONS = 1500;

	virtual task body();
		/* creation of an item object and a set of input values */
		ps2_item item = ps2_item::type_id::create("item");
		start_item(item);		//synchronization with the driver class

		item.ps2_clk = 1'b1;
		item.ps2_data = 1'b1;

		`uvm_info("Generator", $sformatf("No keys pressed"), UVM_LOW)
		finish_item(item);		//synchronization with the driver class

		#DELAY;

		for (int i = 0; i < NUM_OF_ITERATIONS; i++) begin
			/* creation of an item object and a set of input values */
			ps2_item item = ps2_item::type_id::create("item");
			start_item(item); 	//synchronization with the driver class

			manual_randomize(item);

			`uvm_info("Generator", $sformatf("Item %0d/%0d created", i + 1, NUM_OF_ITERATIONS), UVM_LOW)
			finish_item(item); 	//synchronization with the driver class

			#DELAY;
		end

		`uvm_info("Generator", $sformatf("Item generating finished!"), UVM_LOW)
	endtask

	/* constants */
	localparam SEND_START_BIT  = 0 ;
	localparam SEND_PARITY_BIT = 9 ;
	localparam SEND_STOP_BIT   = 10;

	localparam START_BIT_VAL = 1'b0;
	localparam STOP_BIT_VAL  = 1'b1;

	localparam PACKAGE_LENGTH        = 11;				//11 bits (START bit, SCAN_CODE_BYTE[0:7], PARITY bit, STOP bit)
	localparam MAX_MAKE_CODE_LENGTH  = 64;				//make code of the PAUSE key is 64 bits long
	localparam MAX_BREAK_CODE_LENGTH = 48;				//break code of the PRNT SCRN key is 48 bits long

	localparam NUM_OF_KEYBOARD_KEYS        = 98;
	localparam SCAN_CODE_VAR_INITIAL_VALUE = 0 ;

	localparam PRNT_SCRN_MAKE_CODE_VAL  = 64'hE012E07C    ;
	localparam PRNT_SCRN_BREAK_CODE_VAL = 48'hE0F07CE0F012;

	/* variables */
	bit bit_ready_to_send = 1'b1;					//is there a bit to send to the ps2 module

	int       package_bits_counter = 0   ;				//counts the sent bits of the current package
	bit [3:0] ones_counter         = 4'b0;				//count bits 1 in the current scan code byte (SCAN_CODE_BYTE[7:0])

	bit [MAX_MAKE_CODE_LENGTH - 1:0] make_codes [NUM_OF_KEYBOARD_KEYS - 1:0] = {
		/* one byte long codes (break code: F0 XX) */
		64'h1C, //'A'
		64'h32, //'B'
		64'h21, //'C'
		64'h23, //'D'
		64'h24, //'E'
		64'h2B, //'F'
		64'h34, //'G'
		64'h33, //'H'
		64'h43, //'I'
		64'h3B, //'J'
		64'h42, //'K'
		64'h4B, //'L'
		64'h3A, //'M'
		64'h31, //'N'
		64'h44, //'O'
		64'h4D, //'P'
		64'h15, //'Q'
		64'h2D, //'R'
		64'h1B, //'S'
		64'h2C, //'T'
		64'h3C, //'U'
		64'h2A, //'V'
		64'h1D, //'W'
		64'h22, //'X'
		64'h35, //'Y'
		64'h1A, //'Z'

		64'h45, //'0'
		64'h16, //'1'
		64'h1E, //'2'
		64'h26, //'3'
		64'h25, //'4'
		64'h2E, //'5'
		64'h36, //'6'
		64'h3D, //'7'
		64'h3E, //'8'
		64'h46, //'9'

		64'h0E, //'`'
		64'h4E, //'-'
		64'h55, //'='
		64'h54, //'['
		64'h5B, //']'
		64'h4C, //';'
		64'h52, //'’'
		64'h41, //','
		64'h49, //'.'
		64'h4A, //'/'

		64'h11, //L ALT
		64'h59, //R SHFT
		64'h5A, //ENTER
		64'h76, //ESC
		64'h5, 	//F1
		64'h6, 	//F2
		64'h4, 	//F3
		64'h0C, //F4
		64'h3, 	//F5
		64'h0B, //F6
		64'h83, //F7
		64'h0A, //F8
		64'h1, 	//F9
		64'h9, 	//F10
		64'h78, //F11
		64'h7, 	//F12
		64'h7E, //SCROLL

		64'h77, //NUM
		64'h7C, //KP *
		64'h7B, //KP -
		64'h79, //KP +
		64'h71, //KP .
		64'h70, //KP 0
		64'h69, //KP 1
		64'h72, //KP 2
		64'h7A, //KP 3
		64'h6B, //KP 4
		64'h73, //KP 5
		64'h74, //KP 6
		64'h6C, //KP 7
		64'h75, //KP 8
		64'h7D, //KP 9

		/* two bytes long codes (break code: E0 F0 XX) */
		64'hE01F,	//L GUI
		64'hE014, 	//R CTRL
		64'hE027, 	//R GUI
		64'hE011, 	//R ALT
		64'hE02F, 	//APPS

		64'hE070, 	//INSERT
		64'hE06C, 	//HOME
		64'hE07D, 	//PG UP
		64'hE071, 	//DELETE
		64'hE069, 	//END
		64'hE07A, 	//PG DN

		64'hE075, 	//U ARROW
		64'hE06B, 	//L ARROW
		64'hE072, 	//D ARROW
		64'hE074, 	//R ARROW

		64'hE04A, 	//KP /
		64'hE05A, 	//KP EN

		/* other codes */
		64'hF05D, 		//|5D (no break code)
		64'hE11477E1F014F077,	//PAUSE (no break code)

		64'hE012E07C 		//PRNT SCRN (break code: E0,F0,7C,E0,F0,12)
	};

	bit [ MAX_MAKE_CODE_LENGTH-1:0] current_make_code  = SCAN_CODE_VAR_INITIAL_VALUE;	//the value of the current make code to be sent to the ps2 module
	bit [ MAX_MAKE_CODE_LENGTH-1:0] previous_make_code = SCAN_CODE_VAR_INITIAL_VALUE;	//the value of the previous make code
	bit [MAX_BREAK_CODE_LENGTH-1:0] current_break_code = SCAN_CODE_VAR_INITIAL_VALUE;	//the value of the current break code to be sent to the ps2 module

	bit [7:0] current_byte       ;								//the current byte of the 'current_make_code' or 'current_break_code' variable
	bit       send_break   = 1'b0;								//indicates that the 'current_break_code' value is to be sent

	bit prev_ps2data;									//stores the previous value of the ps2_data

	virtual task manual_randomize (ps2_item item);
		/* decides whether the 'current_make_code' or 'current_break_code' is sent */
		if (current_make_code == 64'b0 && package_bits_counter == 0) begin
			/* select a random make code from the group of allowed codes */
			current_make_code = make_codes[$urandom_range(NUM_OF_KEYBOARD_KEYS - 1)];

			/* if the same make code is not selected again (key released), send the break code of the 'previous_make_code' first */
			if (current_make_code != previous_make_code && previous_make_code != SCAN_CODE_VAR_INITIAL_VALUE) begin		//send break code
				if ((previous_make_code & 64'hFFFFFFFFFFFFFF_00) == 64'b0)						//a single byte make code was sent
					current_break_code = { 24'b0, 8'hF0, previous_make_code[7:0] };					//break code is F0 XX
				else if ((previous_make_code & 64'hFFFFFFFFFFFF_00_00) == 64'b0 && previous_make_code != 64'hF05D)	//a double byte make code was sent
					current_break_code = 48'hE0F000 + previous_make_code[7:0];					//break code is E0 F0 XX
				else if (previous_make_code == PRNT_SCRN_MAKE_CODE_VAL)							//the PRNT SCRN make code was sent
					current_break_code = PRNT_SCRN_BREAK_CODE_VAL;

				send_break = 1'b1;											//the 'current_break_code' value is to be sent
			end
			previous_make_code = current_make_code;
		end

		/* send the ps2_data bit */
		if (bit_ready_to_send) begin
			case (package_bits_counter)
				SEND_START_BIT : begin											//send the START bit
					item.ps2_data = START_BIT_VAL;

					/* depending on whether make code or break code is being sent, determine what will be the SCAN_CODE_BYTE[0:7] to be sent */
					if (!send_break) begin										//the 'current_break_code' is being sent
						/* the make code is being sent starting from the highest byte */
						while (current_make_code[MAX_MAKE_CODE_LENGTH - 1-:8] == 8'b0) begin
							current_make_code = current_make_code << 8;
						end
						current_byte = current_make_code[MAX_MAKE_CODE_LENGTH - 1-:8];				//the make code byte that is to be sent
					end else begin
						/* the break code is being sent starting from the highest byte */
						while (current_break_code[MAX_BREAK_CODE_LENGTH - 1-:8] == 8'b0) begin
							current_break_code = current_break_code << 8;
						end
						current_byte = current_break_code[MAX_BREAK_CODE_LENGTH - 1-:8];			//the break code byte that is to be sent
					end
				end

				SEND_PARITY_BIT : item.ps2_data = (ones_counter % 2 == 0) ? 1'b1 : 1'b0; 				//send the PARITY bit (odd parity)
				SEND_STOP_BIT   : item.ps2_data = STOP_BIT_VAL;								//send the STOP bit

				default : begin  											//SCAN_CODE_BYTE[0:7]
					item.ps2_data = current_byte[0];
					current_byte = current_byte >> 1;

					if (item.ps2_data == 1'b1) ones_counter++;
				end
			endcase
		end

		/* the ps2_clk falling edge logic implementation */
		if (bit_ready_to_send) begin		//set ps2_clk to 0 when the ps2_data bit is to be sent
			item.ps2_clk = 1'b0;

			package_bits_counter++;		//one more ps2_data bit is to be sent
			bit_ready_to_send = 1'b0;
		end else begin				//otherwise keep the previous value of the ps2_data a little longer (debouncing)
			item.ps2_data = prev_ps2data;
			item.ps2_clk = 1'b1;

			bit_ready_to_send = 1'b1;	//prepare to send the next ps2_data bit on the falling edge of the ps2_clk signal
		end

		/* after the whole new package was sent */
		if (package_bits_counter == PACKAGE_LENGTH) begin
			package_bits_counter = 0;
			ones_counter = 4'b0;

			/* after the current byte of the make/break code was sent */
			if (!send_break) current_make_code = current_make_code << 8;
			else current_break_code = current_break_code << 8;

			/* after the whole break code was sent */
			if (current_break_code == SCAN_CODE_VAR_INITIAL_VALUE) send_break = 1'b0;
		end

		prev_ps2data = item.ps2_data;
	endtask
endclass

/* sends a set of input data to the DUT interface */
class driver extends uvm_driver #(ps2_item);
	/* registration macro & constructor */
	`uvm_component_utils(driver)

	function new(string name = "driver", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	/* the interface to which we send data */
	virtual ps2_if vif;

	/* the build phase of this component */
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		/* retreive the interface instance */
		if (!uvm_config_db#(virtual ps2_if)::get(this, "", "ps2_vif", vif))
			`uvm_fatal("Driver", "No interface.")	//nakon ispisa fatal poruke prekida se test
	endfunction

	/* the run phase of this component */
	virtual task run_phase(uvm_phase phase);
		super.run_phase(phase);

		forever begin
			/* retereive the item created in the generator (from the sequencer) */
			ps2_item item;
			seq_item_port.get_next_item(item);	//blocking call

			/* printout of item data ('item.print()' could be called instead of 'item.manual_item_print()') */
			`uvm_info("Driver", $sformatf("%s", item.manual_item_print()), UVM_LOW)

			/* send the item to the DUT interface */
			vif.ps2_clk <= item.ps2_clk;
			vif.ps2_data <= item.ps2_data;

			@(posedge vif.clk);
			seq_item_port.item_done();
		end
	endtask
endclass

/* gets the data from the DUT interface */
class monitor extends uvm_monitor;
	/* registration macro & constructor */
	`uvm_component_utils(monitor)

	function new(string name = "monitor", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	/* the interface from which we fetch data */
	virtual ps2_if vif;

	/* analysis_port to send items to the scoreboard component */
	uvm_analysis_port #(ps2_item) mon_analysis_port;

	/* the build phase of this component */
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		/* retreive the interface instance */
		if (!uvm_config_db#(virtual ps2_if)::get(this, "", "ps2_vif", vif))
			`uvm_fatal("Monitor", "No interface.")

		/* initialize the analysis_port instance */
		mon_analysis_port = new("mon_analysis_port", this);
	endfunction

	/* the run phase of this component */
	virtual task run_phase(uvm_phase phase);
		super.run_phase(phase);

		@(posedge vif.clk);
		forever begin
			/* a new item is created (according to the data retrieved from the interface) */
			ps2_item item = ps2_item::type_id::create("item");
			@(posedge vif.clk);
			item.ps2_clk = vif.ps2_clk;
			item.ps2_data = vif.ps2_data;
			item.byte_h_digit_h = vif.byte_h_digit_h;
			item.byte_h_digit_l = vif.byte_h_digit_l;
			item.byte_l_digit_h = vif.byte_l_digit_h;
			item.byte_l_digit_l = vif.byte_l_digit_l;

			/* printout of item data ('item.print()' could be called instead of 'item.manual_item_print()') */
			`uvm_info("Monitor", $sformatf("%s", item.manual_item_print()), UVM_LOW)
			mon_analysis_port.write(item);	//Scoreboard::write() function call
			#DELAY;
		end
	endtask
endclass

/* groups driver, monitor and sequencer */
class agent extends uvm_agent;
	/* registration macro & constructor */
	`uvm_component_utils(agent)

	function new(string name = "agent", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	/* instantiate driver, monitor and sequencer */
	driver  d0;
	monitor m0;
	uvm_sequencer #(ps2_item) s0;

	/* the build phase of this component */
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		/* initialize driver, monitor and sequencer instances */
		d0 = driver::type_id::create("d0", this); //["d0" == instance name, this == parent]
		m0 = monitor::type_id::create("m0", this);
		s0 = uvm_sequencer#(ps2_item)::type_id::create("s0", this);
	endfunction

	/* the connect phase of this component */
	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);

		/* sequencer s0 and driver d0 connection (sequencer -> driver) */
		d0.seq_item_port.connect(s0.seq_item_export);
	endfunction
endclass

/* verifies the logic of the ps2 module */
class scoreboard extends uvm_scoreboard;
	/* registration macro & constructor */
	`uvm_component_utils(scoreboard)

	function new(string name = "scoreboard", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	/* analysis_port to get items from the monitor component */
	uvm_analysis_imp #(ps2_item, scoreboard) mon_analysis_imp;

	/* the build phase of this component */
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		/* initialize the analysis_port instance */
		mon_analysis_imp = new("mon_analysis_imp", this);
	endfunction

	/* variables */
	bit [15:0] scan_code = 15'b0; 			//stores the lowest two bytes of the scan code

	bit [10:0] new_package          = 11'b0; 	//stores one whole package
	bit [ 2:0] ones_counter         = 1'b0 ; 	//count bits 1 in the current scan code byte (SCAN_CODE_BYTE[7:0])
	bit [ 3:0] package_bits_counter = 4'd0 ; 	//counts the sent bits of the current package

	bit received_flag = 1'b0; 			//a whole new package is received
	bit f0_flag       = 1'b0; 			//indicates that the F0 byte has arrived
	bit e0_flag       = 1'b0; 			//indicates that the E0 byte has arrived

	bit ps2_clk_previous; 				//used for the ps2_clk falling edge detection

	bit        fail_flag = 1'b0; 			//necessary in order to bypass the debouncing
	bit [15:0] out             ; 			//output signal that combines multiple outputs of the ps2 module

	/* write() function override */
	virtual function write(ps2_item item);
		get_hex_digit(item.byte_h_digit_h, out[15:12]);
		get_hex_digit(item.byte_h_digit_l, out[11:8]);
		get_hex_digit(item.byte_l_digit_h, out[7:4]);
		get_hex_digit(item.byte_l_digit_l, out[3:0]);

		/* check if the expected value and the output of the module match */
		if (scan_code == out)
			`uvm_info("Scoreboard", $sformatf("PASS! received = %b | expected = %h, got = %h", received_flag, scan_code, out), UVM_LOW)
		else fail_flag = 1'b1;											//to check the if-condition once again at the of this function (debouncing)

		/* programming logic that simulates the module */
		if (package_bits_counter == 4'd0) received_flag = 1'b0;

		if (~item.ps2_clk && ps2_clk_previous) begin
			new_package[package_bits_counter++] = item.ps2_data;						//put the new value of ps2_data into the 'new_package'

			if (package_bits_counter >= 4'd2 && package_bits_counter <= 4'd9)				//ps2_data == SCAN_CODE_BYTE[0:7]
				if (item.ps2_data == 1'b1) ones_counter++;

			/* after the new package has been received */
			if (package_bits_counter == 4'd11) begin
				/* START bit == 0 and STOP bit == 1 and PARITY bit is correct */
				if (new_package[0] == 1'b0 && new_package[10] == 1'b1 && new_package[9] == (ones_counter % 2 == 0 ? 1'b1 : 1'b0)) begin
					case (new_package[8:1])
						8'hF0 : f0_flag = 1'b1;							//do not insert the F0 byte immediately, just mark that it has arrived
						8'hE0 : e0_flag = 1'b1;							//do not insert the E0 byte immediately, just mark that it has arrived

						default : begin
							scan_code = { scan_code[7:0], new_package[8:1] };		//by default just insert the next byte of the scan code

							/* matching the 7SEG display fluidity improvements made in the ps2 module */
							if (scan_code[15:8] == 8'hF0 || scan_code[15:8] == 8'hE0) begin
								scan_code = { 8'b0, new_package[8:1] };
							end else if (scan_code[7:0] == new_package[8:1] && scan_code[7:0] != 8'b0) begin
								scan_code = { 8'b0, new_package[8:1] };
							end

							/* insert the marked F0/E0 byte and the one that just arrived */
							if (f0_flag == 1'b1) begin
								scan_code = { 8'hF0, new_package[8:1] };
								f0_flag = 1'b0;						//clear the f0_flag
								e0_flag = 1'b0;						//necessary due to the situation when we receive E0 F0 respectively
							end else if (e0_flag == 1'b1) begin
								scan_code = { 8'hE0, new_package[8:1] };
								e0_flag = 1'b0;						//clear the e0_flag
								f0_flag = 1'b0;
							end
						end
					endcase
				end

				received_flag = 1'b1;									//the package is received despite any errors it may have

				package_bits_counter = 0;
				ones_counter = 0;
			end
		end

		ps2_clk_previous = item.ps2_clk;

		/* check if the expected value and the output of the module match */
		if (fail_flag) begin
			if (scan_code == out)
				`uvm_info("Scoreboard", $sformatf("PASS! received = %b | expected = %h, got = %h", received_flag, scan_code, out), UVM_LOW)
			else
				`uvm_error("Scoreboard", $sformatf("FAIL! received = %b | expected = %h, got = %h", received_flag, scan_code, out))

			fail_flag = 1'b0;
		end
	endfunction

	virtual function void get_hex_digit(bit [6:0] in, output bit[3:0] out);
		case (in)
			~7'h3F: out = 4'b0000;
			~7'h06: out = 4'b0001;
			~7'h5B: out = 4'b0010;
			~7'h4F: out = 4'b0011;
			~7'h66: out = 4'b0100;
			~7'h6D: out = 4'b0101;
			~7'h7D: out = 4'b0110;
			~7'h07: out = 4'b0111;
			~7'h7F: out = 4'b1000;
			~7'h6F: out = 4'b1001;
			~7'h77: out = 4'b1010;
			~7'h7C: out = 4'b1011;
			~7'h39: out = 4'b1100;
			~7'h5E: out = 4'b1101;
			~7'h79: out = 4'b1110;
			~7'h71: out = 4'b1111;
		endcase
	endfunction
endclass

/* groups agent (driver, monitor and sequencer) and scoreboard */
class env extends uvm_env;
	/* registration macro & constructor */
	`uvm_component_utils(env)

	function new(string name = "env", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	/* instantiate agent and scoreboard */
	agent      a0 ;
	scoreboard sb0;

	/* the build phase of this component */
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		/* initialize agent and scoreboard instances */
		a0 = agent::type_id::create("a0", this);
		sb0 = scoreboard::type_id::create("sb0", this);
	endfunction

	/* the connect phase of this component */
	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);

		/* monitor a0.m0 and scoreboard sb0 connection (monitor -> scoreboard) */
		a0.m0.mon_analysis_port.connect(sb0.mon_analysis_imp);
	endfunction
endclass

/* starts the test */
class test extends uvm_test;
	/* registration macro & constructor */
	`uvm_component_utils(test)

	function new(string name = "test", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	/* the interface through which we communicate with the DUT module */
	virtual ps2_if vif;

	/* instantiate environment and generator */
	env       e0;
	generator g0;

	/* the build phase of this component */
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		/* retreive the interface instance */
		if (!uvm_config_db#(virtual ps2_if)::get(this, "", "ps2_vif", vif))
			`uvm_fatal("Test", "No interface.")

		/* initialize environment and generator instances */
		e0 = env::type_id::create("e0", this);
		g0 = generator::type_id::create("g0");
	endfunction

	/* prints the UVM toplogy tree */
	virtual function void end_of_elaboration_phase(uvm_phase phase);
		uvm_top.print_topology();
	endfunction

	/* the run phase of this component */
	virtual task run_phase(uvm_phase phase);
		phase.raise_objection(this);

		/* the 'apply_reset' task call */
		apply_reset();

		/* start the 'g0' generator and pass it an argument (e0.a0.s0) (generator -> sequencer) */
		g0.start(e0.a0.s0);
		phase.drop_objection(this);
	endtask

	/* task to perform the reset of the ps2 module */
	virtual task apply_reset();
		vif.rst_n <= 0;
		#DELAY vif.rst_n <= 1;
	endtask
endclass

/* the ps2 module interface */
interface ps2_if (
	input bit clk
);

	logic       rst_n         ;
	logic       ps2_clk       ;
	logic       ps2_data      ;
	logic [6:0] byte_h_digit_h;
	logic [6:0] byte_h_digit_l;
	logic [6:0] byte_l_digit_h;
	logic [6:0] byte_l_digit_l;

endinterface

module testbench_verification_uvm ();
	reg clk;

	/* instantiate the physical interface 'dut_if' */
	ps2_if dut_if (.clk(clk));

	/* instantiate the ps2 DUT module to verify */
	ps2 dut (
		.clk           (clk                  ),
		.rst_n         (dut_if.rst_n         ),
		.ps2_clk       (dut_if.ps2_clk       ),
		.ps2_data      (dut_if.ps2_data      ),
		.byte_h_digit_h(dut_if.byte_h_digit_h),
		.byte_h_digit_l(dut_if.byte_h_digit_l),
		.byte_l_digit_h(dut_if.byte_l_digit_h),
		.byte_l_digit_l(dut_if.byte_l_digit_l)
	);

	/* clk */
	initial begin
		clk = 0;
		forever begin
			#1 clk = ~clk; //necessary to simulate fast FPGA clock
		end
	end

	/* testing (verification) of the DUT module */
	initial begin
		/* pass the interface to the 'test' class, since the other classes will need it */
		uvm_config_db#(virtual ps2_if)::set(null, "*", "ps2_vif", dut_if);

		/* start the test defined in the 'test' class */
		run_test("test");
	end
endmodule
