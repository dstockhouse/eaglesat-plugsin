------------------------------------------------------------------------------
-- File:
--	axi_interface.vhd
--
-- Description:
--	Contains an instance of new_latch and interfaces the output of the
--	shift regitser to an AXI stream interface connected to a DMA block.
--
-- Author:
--	David Stockhouse
--
-- Revision 1.5
-- Last edited: 8/20/18
------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;

use IEEE.NUMERIC_STD.ALL;


entity new_latch is
	Port (

		     -- Sensor interface ports
		     d1 : in STD_LOGIC;
		     d2 : in STD_LOGIC;
		     d_ctl : in STD_LOGIC;
		     train_en : in STD_LOGIC;
		     frame_req : in STD_LOGIC;
		     pix_clk : in STD_LOGIC;
		     -- clk : in STD_LOGIC;
		     -- rst : in STD_LOGIC;
		     clr : in STD_LOGIC;
		     out_clk : out STD_LOGIC;
		     -- out_latch : out STD_LOGIC := '0';
		     locked : out STD_LOGIC := '0';
		     -- q1 : out STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
		     -- q2 : out STD_LOGIC_VECTOR (7 downto 0) := (others => '0'));
		     -- q1 : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
		     -- q2 : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0');

		     -- From AXI baremetal example

		     -- AXI slave ports
		     S_AXIS_TREADY	: out	std_logic;
		     S_AXIS_TDATA	: in	std_logic_vector(31 downto 0);
		     S_AXIS_TLAST	: in	std_logic;
		     S_AXIS_TVALID	: in	std_logic;

		     -- AXI master ports
		     M_AXIS_TVALID	: out	std_logic;
		     M_AXIS_TDATA	: out	std_logic_vector(31 downto 0);
		     M_AXIS_TLAST	: out	std_logic;
		     M_AXIS_TREADY	: in	std_logic;

		     -- GPIO control
		     TRIGGER : in std_logic

	     );
end new_latch;

architecture Behavioral of new_latch is


	------ External component declarations ------

	component new_latch
		Port ( d1 : in STD_LOGIC;
		       d2 : in STD_LOGIC;
		       d_ctl : in STD_LOGIC;
		       train_en : in STD_LOGIC;
		       pix_clk : in STD_LOGIC;
		       clk : in STD_LOGIC;
		       rst : in STD_LOGIC;
		       clr : in STD_LOGIC;
		       out_latch : out STD_LOGIC := '0';
		       locked : out STD_LOGIC := '0';
		       q1 : out STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
		       q2 : out STD_LOGIC_VECTOR (7 downto 0) := (others => '0'));
	-- q1 : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
	-- q2 : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0'));
	end component;


	component fifo_generator_8 is
		port (
				 clk : in std_logic;
				 srst : in std_logic;
				 din : in std_logic_vector(7 downto 0);
				 wr_en : in std_logic;
				 rd_en : in std_logic;
				 dout : out std_logic_vector(7 downto 0);
				 full : out std_logic;
				 empty : out std_logic
	--							 data_count : out std_logic_vector (15 downto 0)
			 );
	end component;

	component fifo_generator_16 is
		port (
				 clk : in std_logic;
				 srst : in std_logic;
				 din : in std_logic_vector(15 downto 0);
				 wr_en : in std_logic;
				 rd_en : in std_logic;
				 dout : out std_logic_vector(15 downto 0);
				 full : out std_logic;
				 empty : out std_logic
	--							 data_count : out std_logic_vector (15 downto 0)
			 );
	end component;


	------ Constant definitions ------

	-- Number of pixels in each row (in sensor datasheet)
	constant PIXELS_PER_ROW : natural := 2048;

	-- Number of rows each channel will be reading in (2 channels -> half of 
	-- total number of rows, in sensor datasheet)
	constant ROWS_PER_CHANNEL : natural := (1088 / 2);

	-- Total bytes read in by each channel
	constant NUM_OUTPUT_PIXELS : natural := (PIXELS_PER_ROW * ROWS_PER_CHANNEL);

	-- Amount to divide the input clock to make the CMV output clock 5MHz
	constant CLOCK_DIV : natural := 20;


	------ Internal signal declarations ------

	-- Internal 30-bit buffers from the serial data output from the sensor
	signal int_q1, int_q2, int_ctl : std_logic_vector (29 downto 0);
	-- If outputting entire words, need longer buffers
	-- signal int_q1, int_q2, int_ctl : std_logic_vector (59 downto 0);

	-- Offset locations from which to draw each pixel from the 30-bit buffer
	signal offset1, offset2, offset_ctl : integer := 0;

	-- Internal signal for whether or not the device is currently training
	signal int_train : std_logic := '1';

	-- Signal to clear the DDR shift register but not reset the framing of the system
	signal ddr_rst : std_logic;



	-- Finite state machine states
	type STATE_TYPE is (Idle, Read_Inputs, Write_Outputs);
	signal state : STATE_TYPE;

	-- Counter to divide the clock down to a reasonable output frequency
	signal output_counter : integer range 0 to CLOCK_DIV - 1 := CLOCK_DIV - 1;
	signal row_counter : integer range 0 to PIXELS_PER_ROW - 1 := PIXELS_PER_ROW - 1;

	-- Counters to store the number inputs read & outputs written
	signal nr_of_writes : natural range 0 to (ROWS_PER_CHANNEL - 1 := NUMBER_OF_OUTPUT_WORDS - 1;

	-- FIFO signals
	signal fifo_input_lsb, fifo_output_lsb : std_logic_vector (31 downto 0);
	signal fifo_input_msb, fifo_output_msb : std_logic_vector (31 downto 0);
	signal fifo_input_combined, fifo_output_combined : std_logic_vector (31 downto 0);

	signal fifo_rden_lsb, fifo_wren_lsb, fifo_full_lsb, fifo_empty_lsb, fifo_rst_lsb : std_logic;
	signal fifo_rden_msb, fifo_wren_msb, fifo_full_msb, fifo_empty_msb, fifo_rst_msb : std_logic;
	signal fifo_rden_combined, fifo_wren_combined, fifo_full_combined, fifo_empty_combined, fifo_rst_combined : std_logic;

	-- Buffer signals for AXI interface
	signal sig_m_tvalid, sig_m_tlast : std_logic;
	-- signal sig_m_tdata : std_logic_vector(31 downto 0);

begin

	-- Component instance port maps
	FIFO_LSB_INST : fifo_generator_8 port map ( clk => clk,
						srst => fifo_rst,
						din => fifo_input_lsb,
						wr_en => fifo_wren_lsb,
						rd_en => fifo_rden_lsb,
						dout => fifo_output_lsb,
						full => fifo_full_lsb,
						empty => fifo_empty_lsb,
					);
	FIFO_MSB_INST : fifo_generator_8 port map ( clk => clk,
						srst => fifo_rst,
						din => fifo_input_msb,
						wr_en => fifo_wren_msb,
						rd_en => fifo_rden_msb,
						dout => fifo_output_msb,
						full => fifo_full_msb,
						empty => fifo_empty_msb,
					);
	FIFO_COMBINED_INST : fifo_generator_16 port map ( clk => clk,
						srst => fifo_rst,
						din => fifo_input_combined,
						wr_en => fifo_wren_combined,
						rd_en => fifo_rden_combined,
						dout => fifo_output_combined,
						full => fifo_full_combined,
						empty => fifo_empty_combined,
					);

	INTERFACE_INST : new_latch port map ( d1 => d1,
					      d2 => d2,
					      d_ctl => d_ctl,
					      train_en => train_en,
					      pix_clk => pix_clk,
					      clk => clk,
					      rst => rst,
					      clr => clr,
					      out_latch => out_latch,
					      locked => locked,
					      q1 => ,
					      q2 => q2,
				      );

	-- FIFO signal assignments
	fifo_rst <= not rst;

	-- LSB FIFO signals
	fifo_input_lsb <= d1;
	fifo_wren_lsb <= pass;
	fifo_rden_lsb <= pass;

	-- MSB FIFO signals
	fifo_input_msb <= d1;
	fifo_wren_msb <= pass;
	fifo_rden_msb <= '1' when fifo_full_combined = '0' else '0';

	-- Combined FIFO signals
	fifo_input_combined <= fifo_output_msb & fifo_output_lsb;
	fifo_wren_combined <= '1' when (fifo_empty_lsb = '0') and (fifo_empty_msb = '0') else '0';
	fifo_rden_combined <= '1' when (M_AXIS_TREADY = '1') and (sig_m_tvalid = '1') else '0';


	-- Interface signal assignments

	MAIN_PROC : process(clk, rst)
	begin

	end process; -- MAIN_PROC

end Behavioral;
