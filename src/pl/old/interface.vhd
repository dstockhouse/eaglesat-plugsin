------------------------------------------------------------------------------
-- File:
--	interface.vhd
--
-- Description:
--	This is the interface to the CMV2000 CMOS active pixel sensor. The
--	sensor outputs pixel data through 2 DDR LVDS 10-bit serial pixel data
--	channels and 1 control data channel along with a 50 MHz clock (DDR).
--	This interface shifts in the serial data lines and first
--	synchronizes the phase of the clock against a known training
--	sequence output by the 2 pixel data channels whenever valid pixel
--	data is not available. The control channel conveys information about
--	whether or not the data coming from the pixel data channels is valid
--	pixel data or training data. Once the training data has been
--	synchronized, the interface waits until the sensor starts outputting
--	valid pixel data. Serial pixel data from the sensor's 2 channels is
--	shifted into two 40-bit (4 x 10-bit) shift registers. The 2 least
--	significant bits from each 10-bit word are dropped so that the
--	shifted data latches into two 32-bit (4 x 8-bit) buffer registers.
--	These buffers (which may not be necessary) are fed into the FIFO
--	block inputs to the Xillybus interface to Xillinux running on the
--	processing system (PS), 32 bits at a time to each FIFO. This data
--	will be read by software running on the PS.
--
-- Author:
--	David Stockhouse & Sam Janoff
--
-- Revision 1.5
-- Last edited: 7/26/18
------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;

use IEEE.NUMERIC_STD.ALL;


entity interface is
	Port ( d : in STD_LOGIC;
	       train_en : in STD_LOGIC;
	       train : in STD_LOGIC_VECTOR (9 downto 0);
	       pix_clk : in STD_LOGIC;
	       clk : in STD_LOGIC;
	       rst : in STD_LOGIC;
	       out_latch : out STD_LOGIC := '0';
	       locked : out STD_LOGIC := '0';
	       q : out STD_LOGIC_VECTOR (7 downto 0) := (others => '0'));
end interface;

architecture Behavioral of interface is


	------ External component declarations ------

	component DDRlatch is
		Port ( d : in STD_LOGIC;
		       clk : in STD_LOGIC;
		       rst : in STD_LOGIC;
		       latch : out STD_LOGIC;
		       q : out STD_LOGIC_VECTOR (9 downto 0));
	end component;

	component pll_wrapper is
		Port ( clk : in STD_LOGIC;
		       rst : in STD_LOGIC;
		       clk_out : out STD_LOGIC_VECTOR ( 5 downto 0 );
		       locked : out STD_LOGIC);
	end component;

	component match is
		Port ( test : in STD_LOGIC_VECTOR (9 downto 0);
		       key : in STD_LOGIC_VECTOR (9 downto 0);
		       train_en : in STD_LOGIC;
		       rst : in STD_LOGIC;
		       matched : out STD_LOGIC;
		       shifted : out STD_LOGIC_VECTOR (9 downto 0);
		       shift : out INTEGER);
	end component;

	component clock_select is
		Port ( clk_sel : in STD_LOGIC_VECTOR (5 downto 0);
		       train_en : in STD_LOGIC;
		       rst : in STD_LOGIC;
		       chosen : out integer;
		       confident : out STD_LOGIC);
	end component;


	------ Internal signal declarations ------

	-- Clock signals that are each out of phase a certain amount from the
	-- main clock
	signal phase_clk : std_logic_vector(5 downto 0);

	-- Internal shift register latch signal and inverted clock
	signal int_latch, inv_clk, pll_locked : std_logic;

	-- The type phase_set is an array of ten bit vectors representing the
	-- six words shifted in by each phase clock
	type phase_set is array (0 to 5) of std_logic_vector (9 downto 0);
	signal internal : phase_set := (others => (others => '0'));
	signal internal_shifted : phase_set := (others => (others => '0'));

	-- clk_sel is a boolean representing which phase clocks have
	-- the correct training data, even if it's shifted a few bits
	signal clk_sel : std_logic_vector(0 to 5) := (others => '0');

	-- clk_choice is which of the phase clocks is selected as the
	-- correct phase for the input line
	signal clk_choice : integer := 0;

	-- sel is an array of integers that keeps track of which
	-- phased clocks shifted the correct data and if they are
	-- a discrete number of bits out of sync
	-- shift_sel keeps track of how many bits the correctly 
	-- phased clocks are out of sync
	type sel is array (0 to 5) of integer;
	signal shift_sel : sel := (others => 0);

	-- qtemp is the 10-bit output latched from the serial input line
	signal qtemp : std_logic_vector (9 downto 0);

begin

	-- Inverted clock
	inv_clk <= '0' when rst = '1' else
		   not clk;


	-- Clock phase generating PLL block. Wrapper around block design
	PLL_INST : pll_wrapper port map(clk => clk,
					rst => rst,
					clk_out => phase_clk,
					locked => pll_locked);

	-- Setup six ten-bit latched DDR shift registers (from DDRlatch.vhd)
	SHIFT_CHANNELS : for I in 0 to 5 generate

		-- A single data line
		SHIFT_GEN : DDRlatch port map(d => d,
					      clk => phase_clk(I),
					      rst => rst,
					      latch => int_latch,
					      q => internal(I));

	end generate SHIFT_CHANNELS;


	-- Count to ten on the DDR clock and set the internal latch, then
	-- check the internal signals to see if they match the training
	-- data
	COUNT_PROC : process(clk, inv_clk, rst)

		-- Counter variable, initialize to 0
		variable count : integer := 0;

	begin

		-- Check reset signal, set all signals to 0
		if rst = '0' then

			-- Check for rising or falling edge (rising on inv_clk
			if rising_edge(clk) or rising_edge(inv_clk) then

				-- Increment counter
				count := count + 1;

				-- If latch is set, reset it
				if(clk = '1' and int_latch = '1') then
					int_latch <= '0';
				end if;

				-- If count reached 10, set internal latch
				if(count >= 10) then
					if(clk = '1') then
						int_latch <= '1';
					end if;
					count := 0;
				end if;

			end if; -- DDR edge detector

		else

			int_latch <= '0';
			out_latch <= '0';
			count := 0;

		end if; -- rst

	end process; -- COUNT_PROC


	-- Generate the training data comparison blocks
	COMPARE : for I in 0 to 5 generate

		SHIFT_COMPARE : match port map (test => internal(I),
						key => train,
						train_en => train_en,
						rst => rst,
						matched => clk_sel(I),
						shifted => internal_shifted(I),
						shift => shift_sel(I));

	end generate COMPARE;


	-- Select the right clock based on the value of clk_sel
	FINAL_SELECTION : clock_select port map (clk_sel => clk_sel,
						 train_en => train_en,
						 rst => rst,
						 chosen => clk_choice,
						 confident => locked);


	-- Assign output to the properly selected and shifted input phase
	qtemp <= (others => '0') when rst = '1' or (clk_choice < 0 or clk_choice > 5) else
		 internal_shifted(clk_choice);
		 -- to_stdlogicvector(to_bitvector(internal(clk_choice)) rol conv_integer(shift_sel(clk_choice)));

	-- Trim the 2 LSBs for the final latched output
	q <= (others => '0') when rst = '1' else
	     qtemp (9 downto 2);

end Behavioral;
