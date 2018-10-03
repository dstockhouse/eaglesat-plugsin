------------------------------------------------------------------------------
-- hw_acc - entity/architecture pair
------------------------------------------------------------------------------
--
-- ***************************************************************************
-- ** Copyright (c) 1995-2012 Xilinx, Inc.  All rights reserved.            **
-- **                                                                       **
-- ** Xilinx, Inc.                                                          **
-- ** XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"         **
-- ** AS A COURTESY TO YOU, SOLELY FOR USE IN DEVELOPING PROGRAMS AND       **
-- ** SOLUTIONS FOR XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE,        **
-- ** OR INFORMATION AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,        **
-- ** APPLICATION OR STANDARD, XILINX IS MAKING NO REPRESENTATION           **
-- ** THAT THIS IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,     **
-- ** AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE      **
-- ** FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY              **
-- ** WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE               **
-- ** IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR        **
-- ** REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF       **
-- ** INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS       **
-- ** FOR A PARTICULAR PURPOSE.                                             **
-- **                                                                       **
-- ***************************************************************************
--
------------------------------------------------------------------------------
-- Filename:          hw_acc
-- Version:           1.00.a
-- Description:       Example Axi Streaming core (VHDL).
-- Date:              Mon Sep 15 15:41:21 2014 (by Create and Import Peripheral Wizard)
-- VHDL Standard:     VHDL'93
------------------------------------------------------------------------------
-- Naming Conventions:
--   active low signals:                    "*_n"
--   clock signals:                         "clk", "clk_div#", "clk_#x"
--   reset signals:                         "rst", "rst_n"
--   generics:                              "C_*"
--   user defined types:                    "*_TYPE"
--   state machine next state:              "*_ns"
--   state machine current state:           "*_cs"
--   combinatorial signals:                 "*_com"
--   pipelined or register delay signals:   "*_d#"
--   counter signals:                       "*cnt*"
--   clock enable signals:                  "*_ce"
--   internal version of output port:       "*_i"
--   device pins:                           "*_pin"
--   ports:                                 "- Names begin with Uppercase"
--   processes:                             "*_PROCESS"
--   component instantiations:              "<ENTITY_>I_<#|FUNC>"
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------------
--
--
-- Definition of Ports
-- ACLK              : Synchronous clock
-- ARESETN           : System reset, active low
-- S_AXIS_TREADY  : Ready to accept data in
-- S_AXIS_TDATA   :  Data in
-- S_AXIS_TLAST   : Optional data in qualifier
-- S_AXIS_TVALID  : Data in is valid
-- M_AXIS_TVALID  :  Data out is valid
-- M_AXIS_TDATA   : Data Out
-- M_AXIS_TLAST   : Optional data out qualifier
-- M_AXIS_TREADY  : Connected slave device is ready to accept data out
--
-------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Entity Section
------------------------------------------------------------------------------

entity cmv_interface is
	port
	(
		-- DO NOT EDIT BELOW THIS LINE ---------------------
		-- Bus protocol ports, do not add or delete.
		ACLK	: in	std_logic;
		ARESETN	: in	std_logic;
		M_AXIS_TVALID	: out	std_logic;
		M_AXIS_TDATA	: out	std_logic_vector(31 downto 0);
		M_AXIS_TLAST	: out	std_logic;
		M_AXIS_TREADY	: in	std_logic;
		-- DO NOT EDIT ABOVE THIS LINE ---------------------
		PS_TO_PL : in std_logic_vector (31 downto 0);
		PL_TO_PS : out std_logic_vector (31 downto 0);

		-- CMV interface signals
		lvds_clk : in STD_LOGIC;
		d1 : in STD_LOGIC;
		d2 : in STD_LOGIC;
		d_ctl : in STD_LOGIC;
		train_en : in STD_LOGIC;
		pix_clk : in STD_LOGIC;

		-- Debugging signals
		fifo_count : out std_logic_vector (10 downto 0);
		num_left : out std_logic_vector (31 downto 0)
	);

	attribute SIGIS : string;
	attribute SIGIS of ACLK : signal is "Clk";

end cmv_interface;

------------------------------------------------------------------------------
-- Architecture Section
------------------------------------------------------------------------------

-- In this section, we povide an example implementation of ENTITY hw_acc
-- that does the following:
--
-- 1. Read all inputs
-- 2. Add each input to the contents of register 'sum' which
--    acts as an accumulator
-- 3. After all the inputs have been read, write out the
--    content of 'sum' into the output stream NUMBER_OF_OUTPUT_WORDS times
--
-- You will need to modify this example or implement a new architecture for
-- ENTITY hw_acc to implement your coprocessor

architecture Behavioral of cmv_interface is

	component fifo_32x2k is
		port (
			     clk : in std_logic;
			     srst : in std_logic;
			     din : in std_logic_vector(31 downto 0);
			     wr_en : in std_logic;
			     rd_en : in std_logic;
			     dout : out std_logic_vector(31 downto 0);
			     full : out std_logic;
			     empty : out std_logic;
			     data_count : out std_logic_vector (10 downto 0)
		     );
	end component;

	component hw_interface is
		Generic (
				-- The only acceptable values are 1, 2, and 4
				pixels_per_word : integer := 2
			);
		Port ( 
			     d1 : in STD_LOGIC;
			     d2 : in STD_LOGIC;
			     d_ctl : in STD_LOGIC;
			     train_en : in STD_LOGIC;
			     pix_clk : in STD_LOGIC;
			     clk : in STD_LOGIC;
			     rst : in STD_LOGIC;
			     clr : in STD_LOGIC;
			     out_latch : out STD_LOGIC := '0';
			     locked : out STD_LOGIC := '0';
			     q1 : out STD_LOGIC_VECTOR ((pixels_per_word * 8) - 1 downto 0) := (others => '0');
			     q2 : out STD_LOGIC_VECTOR ((pixels_per_word * 8) - 1 downto 0) := (others => '0')
		     );
	end component;


	-- Characteristics of the image sensor
	constant PIXELS_PER_ROW : natural := 2048;
	constant NUM_ROWS : natural := 1088;
	constant PIXELS_PER_WORD : natural := 4;

	-- Output sizes for one image, i.e. some dimensional analysis with 1 packet per row
	--     words = (pix/row) * (rows) / (pix/word)
	--	signal NUMBER_OF_OUTPUT_WORDS : natural := (PIXELS_PER_ROW * NUM_ROWS / PIXELS_PER_WORD);
	--	signal NUMBER_OF_OUTPUT_PACKETS : natural := (NUM_ROWS / 2);
	constant NUMBER_OF_OUTPUT_WORDS : natural := (PIXELS_PER_ROW * NUM_ROWS / PIXELS_PER_WORD);
	constant NUMBER_OF_OUTPUT_PACKETS : natural := (NUM_ROWS / 2);
	--     words / row = (pix/row) / (pix/word)
	--	constant PACKET_SIZE : natural := PIXELS_PER_ROW / PIXELS_PER_WORD;
	--    signal PACKET_SIZE : natural := 128;
	--    signal CLOCK_DIV : natural := 40;
	--    constant PACKET_SIZE : natural := 128;
	--    constant PACKET_SIZE : natural := PIXELS_PER_ROW * NUM_ROWS / PIXELS_PER_WORD;
	constant PACKET_SIZE : natural := NUMBER_OF_OUTPUT_WORDS;
	constant CLOCK_DIV : natural := 40;

	type STATE_TYPE is (Idle, Write_Outputs);

	signal state : STATE_TYPE;

	-- Two sums, one counts up and the other down
	signal sum : std_logic_vector(31 downto 0);
	--	signal sum1, sum2 : std_logic_vector(15 downto 0);

	-- Counter to divide the clock down to a reasonable output frequency
	--	signal output_counter : integer range 0 to CLOCK_DIV - 1 := CLOCK_DIV - 1;
	signal packet_counter : integer range 0 to PACKET_SIZE - 1 := PACKET_SIZE - 1;
	signal output_counter : integer := CLOCK_DIV - 1;
	--    signal packet_counter : integer := 31;

	-- Counters to store the number outputs written
	signal nr_of_writes : natural := 31;

	-- FIFO signals
	signal fifo_input, fifo_output : std_logic_vector (31 downto 0);
	signal fifo_datacount : std_logic_vector (10 downto 0);
	signal fifo_rden, fifo_wren, fifo_full, fifo_empty, fifo_rst : std_logic;

	constant FIFO_DELAY : natural := 4;
	signal fifo_delay_counter : natural := FIFO_DELAY - 1;


	-- Interface signals
	signal int_q1, int_q2 : std_logic_vector (15 downto 0);
	signal int_rst, int_locked, int_latch, int_clr : std_logic;
	signal write_to_fifo : std_logic;



	-- Buffer signals for AXI interface
	signal sig_m_tvalid, sig_m_tlast : std_logic;
	-- signal sig_m_tdata : std_logic_vector(31 downto 0);


	-- Parsing flags to and from the PS
	signal TRIGGER, OVERFLOW : std_logic;
	signal left_at_overflow : std_logic_vector(30 downto 0);

begin

	---- FIFO components and signals

	FIFO_INST : fifo_32x2k
	port map (
			 clk => ACLK,
			 srst => fifo_rst,
			 din => fifo_input,
			 wr_en => fifo_wren,
			 rd_en => fifo_rden,
			 dout => fifo_output,
			 full => fifo_full,
			 empty => fifo_empty,
			 data_count => fifo_datacount
		 );

	-- Debugging signal for number of values stored in FIFO
	fifo_count <= fifo_datacount;

	-- Non-inverted reset
	-- fifo_rst <= not ARESETN;

	-- Output number of words left to write, which is already being counted
	fifo_input <= int_q2 & int_q1;

	-- Output data from FIFO if source valid (FIFO not empty) and DMA ready
	fifo_rden <= '1' when (fifo_empty = '0') and (M_AXIS_TREADY = '1') else '0';

	-- Read out to FIFO what used to be TVALID output
	-- fifo_wren <= '1' when (state = Write_Outputs) and (output_counter = 0) else '0';

	-- If FIFO is not empty, read out of FIFO. Also takes care of undefined FIFO signals
	-- sig_m_tvalid is assigned in the process statement
	M_AXIS_TVALID <= sig_m_tvalid;


	---- CMV interface components and signals

	INTERFACE_INST : hw_interface 
	generic map (
			    -- The only acceptable values are 1, 2, and 4
			    pixels_per_word => 2
		    )
	port map ( 
			 d1 => d1,
			 d2 => d2,
			 d_ctl => d_ctl,
			 train_en => train_en,
			 pix_clk => pix_clk,
			 clk => lvds_clk,
			 rst => int_rst,
			 clr => int_clr,
			 out_latch => int_latch,
			 locked => int_locked,
			 q1 => int_q1,
			 q2 => int_q2
		 );

	-- Not inverted reset
	int_rst <= not ARESETN;


	---- AXI signals

	-- TLAST high if valid data at end of a packet
	M_AXIS_TLAST <= sig_m_tlast;
	sig_m_tlast <= '1' when (sig_m_tvalid = '1') and (packet_counter = 0) else '0';

	-- AXI output is the output of the FIFO
	M_AXIS_TDATA <= fifo_output;


	-- Parse signals to and from processor
	TRIGGER <= PS_TO_PL(0);
	--    NUMBER_OF_OUTPUT_WORDS <= PACKET_SIZE * NUMBER_OF_OUTPUT_PACKETS;

	--	PL_TO_PS(0) <= OVERFLOW;
	--	PL_TO_PS(31 downto 1) <= left_at_overflow(30 downto 0);
	PL_TO_PS <= (others => '0');

	num_left <= std_logic_vector(to_unsigned(nr_of_writes, 32));

	LATCH_PROC : process (ACLK, int_latch) is
	begin

		if int_latch'event and int_latch = '1' then

			write_to_fifo <= '1';

		end if;

		if ACLK'event and ACLK = '1' then     -- Rising clock edge
			if ARESETN = '0' then               -- Synchronous reset (active low)
							    -- CAUTION: make sure your reset polarity is consistent with the
							    -- system reset polarity
				state <= Idle;
				nr_of_writes <= NUMBER_OF_OUTPUT_WORDS - 1;
				fifo_delay_counter <= FIFO_DELAY - 1;
				sum <= (others => '0');
				output_counter <= CLOCK_DIV - 1;
				packet_counter <= PACKET_SIZE - 1;
				fifo_rst <= '1';
				fifo_wren <= '0';
				fifo_rden <= '0';

				sig_m_tvalid <= '0';
--                OVERFLOW <= '0';


			else -- ARESETN

				fifo_rst <= '0';

				if fifo_rden = '1' then
					sig_m_tvalid <= '1';
				else
					sig_m_tvalid <= '0';
				end if;

				fifo_wren <= '0';
				if write_to_fifo = '1' then
					fifo_wren <= '1';
					write_to_fifo <= '0';
				end if;



				case state is
					when Idle =>
						if TRIGGER = '1' then
							state       <= Write_Outputs;
							nr_of_writes <= NUMBER_OF_OUTPUT_WORDS - 1;
							sum <= (others => '0');
							output_counter <= CLOCK_DIV - 1;
							packet_counter <= PACKET_SIZE - 1;
							fifo_delay_counter <= FIFO_DELAY - 1;
--							OVERFLOW <= '0';
--							left_at_overflow <= (others => '0');

						-- Latch input GPIO to respective positions
--							if to_integer(unsigned(PS_TO_PL(9 downto 1))) > 0 then
--                                CLOCK_DIV <= to_integer(unsigned(PS_TO_PL(9 downto 1)));
--                            end if;
--                            if to_integer(unsigned(PS_TO_PL(19 downto 10))) > 0 then
--                                PACKET_SIZE <= to_integer(unsigned(PS_TO_PL(19 downto 10)));
--                            end if;
--                            if to_integer(unsigned(PS_TO_PL(31 downto 20))) > 0 then
--                                NUMBER_OF_OUTPUT_PACKETS <= to_integer(unsigned(PS_TO_PL(31 downto 20)));
--                            end if;
						end if;

					when Write_Outputs =>
						if output_counter > 0 then
							output_counter <= output_counter - 1;
						else

							if (nr_of_writes = 0) then
								state <= Idle;
							else
								nr_of_writes <= nr_of_writes - 1;
							end if;

							output_counter <= CLOCK_DIV - 1;

							if sum = X"FFFFFFFF" then
								sum <= (others => '0');
							else
								sum <= std_logic_vector(unsigned(sum) + 1);
							end if;

						--                            if sum1 = X"FFFF" then
						--                                sum1 <= (others => '0');
						--                            else
						--                                sum1 <= std_logic_vector(unsigned(sum1) + 1);
						--                            end if;

						--							if sum2 = X"0000" then
						--								sum2 <= (others => '1');
						--							else
						--								sum2 <= std_logic_vector(unsigned(sum2) - 1);
						--							end if;

						end if; -- output_counter
				end case; -- state

				if sig_m_tvalid = '1' then

					if (packet_counter = 0) then
						packet_counter <= PACKET_SIZE - 1;
					else
						packet_counter <= packet_counter - 1;
					end if;

				end if; -- fifo_rden

			--				if fifo_full = '1' then

			--				    -- Set overflow flag
			--				    OVERFLOW <= '1';

			--                end if; -- fifo_full

			--                if OVERFLOW = '1' and to_integer(unsigned(left_at_overflow)) = 0 then
			--                     left_at_overflow <= std_logic_vector(to_unsigned(nr_of_writes, left_at_overflow'length));
			--                end if;

			end if; -- ARESETN

		end if; -- Rising edge of ACLK

	end process; -- WRITE_TO_FIFO

end architecture Behavioral;
