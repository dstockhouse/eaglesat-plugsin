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
-- Revision 1.2
-- Last edited: 3/9/18
------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use IEEE.NUMERIC_STD.ALL;


entity interface is
	Port ( D : in STD_LOGIC;
	       rst : in STD_LOGIC;
	       clk : in STD_LOGIC;
	       pix_clk : in STD_LOGIC;
	       train_en : in STD_LOGIC;
	       train : in STD_LOGIC_VECTOR (9 downto 0);
	       latch_sig : out STD_LOGIC := '0';
	       locked : out STD_LOGIC := '0';
	       Q : out STD_LOGIC_VECTOR (7 downto 0) := (others => '0'));
end interface;

architecture Behavioral of interface is

	component DDRlatch is
		Port ( D : in STD_LOGIC;
		       clk : in STD_LOGIC;
		       rst : in STD_LOGIC;
		       latch : in STD_LOGIC;
		       Q : out STD_LOGIC_VECTOR (9 downto 0));
	end component;

	component PLL_phase_wrapper is
		Port ( clk_in : in STD_LOGIC;
		       clk_out : out STD_LOGIC_VECTOR ( 5 downto 0 );
		       locked : out STD_LOGIC;
		       rst : in STD_LOGIC);
	end component;

	component bit_sum is
		Port ( bits : in STD_LOGIC_VECTOR (5 downto 0);
		       rst : in STD_LOGIC;
		       count : out integer);
	end component;

	component gap_counter is
		Port ( bits : in STD_LOGIC_VECTOR (5 downto 0);
		       rst : in STD_LOGIC;
		       count : out integer);
	end component;

	-- Clock signals that are each out of phase a certain amount from the
	-- main clock
	signal phase_clk : std_logic_vector(5 downto 0);

	-- Internal shift register latch signal and inverted clock
	signal int_latch, inv_clk, pll_locked : std_logic;

	-- The type /shifted/ is an array of ten bit vectors representing the
	-- six words shifted in by each phase clock
	type shifted is array (0 to 5) of std_logic_vector (9 downto 0);
	signal internal : shifted := (others => (others => '0'));



	-- /clk_sel/ is a boolean representing which phase clocks have
	-- the correct training data, even if it's shifted a few bits
	signal clk_sel : std_logic_vector(0 to 5);

	-- /clk_choice/ is which of the phase clocks is selected as the
	-- correct phase for the input line
	signal clk_choice : integer := 0;

	-- /gap_sel/ is used for detecting how many gaps between 1's are in
	-- /clk_sel/. Used in gap_counter.vhd
	signal gap_sel : std_logic_vector (5 downto 0) := (others => 'L');
	signal gap_rst : std_logic;

	-- /num_clks/ keeps track of how many bits in clk_sel are set
	-- /num_gaps/ keeps track of how many gaps between 1's there are
	signal num_clks, num_gaps : integer := 0;

	-- /choice/ is an array of integers that keeps track of which
	-- phased clocks shifted the correct data and if they are
	-- a discrete number of bits out of sync
	type choice is array (0 to 5) of integer;

	-- /shift_sel/ keeps track of how many bits the correctly 
	-- phased clocks are out of sync
	signal shift_sel : choice;
	signal start_sel, end_sel : std_logic_vector (5 downto 0);

	-- Keep track of which clock phase starts to correctly read
	-- data and which clock phase ends that loop
	signal start_choice, end_choice : integer := 6;


	signal count : integer := 0;

	signal temp : std_logic_vector (9 downto 0);
	signal qtemp : std_logic_vector (7 downto 0);
    
begin

	-- Inverted clock
	inv_clk <= not clk;


	-- Clock phase generating PLL block. Wrapper around block design
	PLL_INST : PLL_phase_wrapper port map(clk_in => clk,
					      clk_out => phase_clk,
					      locked => pll_locked,
					      rst => rst);

	-- Setup six ten-bit latched DDR shift registers (from DDRlatch.vhd)
	SHIFT6x10 : for I in 0 to 5 generate

		-- Data line
		SHIFT_GEN : DDRlatch port map(D => D,
					       clk => phase_clk(I),
					       rst => rst,
					       latch => int_latch,
					       Q => internal(I));


	end generate SHIFT6x10;


	-- Count to ten on the DDR clock and set the internal latch, then
	-- check the internal signals to see if they match the training
	-- data
	COUNT_PROC : process(clk, inv_clk, rst)

	begin

		-- Check reset signal, set all signals to 0
		if rst = '1' then

			int_latch <= '0';
			latch_sig <= '0';

			count <= 0;

		else

			-- Check for rising or falling edge (rising on inv_clk
			if rising_edge(clk) or rising_edge(inv_clk)
			then

				-- Increment counter
				count <= count + 1;

				-- If latch is set, reset it
				if int_latch = '1' then
					int_latch <= '0';
				end if;

				-- If count reached 10, set internal latch
				if count >= 9 then
					int_latch <= '1';
					count <= 0;
				end if;

			end if; -- DDR rising edge

		end if; -- rst

	end process; -- COUNT_PROC


	-- If internal latch has been set, check shifted data against training
	-- data
	LATCH_PROC : process(int_latch, rst)

	begin

		TRAIN_CHECK : if rst = '1' then

			clk_sel <= (others => '0');
			shift_sel <= (others => 0);

		elsif rising_edge(int_latch) and train_en = '1' then

			-- Initialize clock and shift variables to 0
			clk_sel <= (others => '0');
			shift_sel <= (others => 0);

			-- Loop through the phase clocks to find which ones match
			CLOCK_LOOP : for C in 0 to 5 loop
			-- Loop through all 10 bits to see if shifting the 
			-- input from the clocks will make the data line up
				BIT_LOOP : for S in 0 to 9 loop
					-- If it matches the training data, then set
					-- that bit in /clk_sel/ and save the shift
					-- in shift_sel
					temp <= to_stdlogicvector(to_bitvector(internal(C)) rol S);
					temp <= internal(C);
					if internal(C) = train and not (clk_sel(C) = '1') then
						clk_sel(C) <= '1';
						shift_sel(C) <= S;
					end if;

				end loop; -- BIT_LOOP

			end loop; -- CLOCK_LOOP

		end if; -- TRAIN_CHECK

	end process; -- LATCH_PROC



	-- Count the bits in clk_sel

	SUM : bit_sum port map (bits => clk_sel,
				rst => gap_rst,
				count => num_clks);


	-- Count the gaps between 1's in clk_sel
	gap_rst <= rst or (not train_en);
	GAPS : gap_counter port map (bits => clk_sel,
				     rst => gap_rst,
				     count => num_gaps);


	-- Find the start and end points of the selected clocks
	SELECT_GEN : for I in 0 to 5 generate

		-- Determine if this bit is the start of a long continuity
		start_sel(I) <= '0' when rst = '1' else
				'1' when (clk_sel(I) = '1') and
				(clk_sel((I - 1) mod 6) = '0') and
				(clk_sel((I + 1) mod 6) = '1') and
				(train_en = '1') else
				'L';

		-- Determine if this bit is the end of a long continuity
		end_sel(I) <= '0' when rst = '1' else
			      '1' when (clk_sel(I) = '1') and
			      (clk_sel((I - 1) mod 6) = '1') and
			      (clk_sel((I + 1) mod 6) = '0') and
			      (train_en = '1') else
			      'L';

	end generate SELECT_GEN;


	-- Based on all the values of start_sel and end_sel, choose the actual
	-- start and end points
	FINAL_SELECTION : process(start_sel, end_sel) 

	begin

		TRAIN_CHECK : if rst = '1' then

			start_choice <= 0;
			end_choice <= 0;

		elsif train_en = '1' and pll_locked = '1' then
			CHOICE : for I in 0 to 5 loop

				if start_sel(I) = '1' then

				-- Set the choice to this number
					start_choice <= I;
				end if;


				if end_sel(I) = '1' then

				-- Set the choice to this number
					end_choice <= I;
				end if;


			end loop; -- CHOICE

		end if; -- TRAIN_CHECK

	end process; -- FINAL_SELECTION


	-- Assign proper output based on correct clock
	clk_choice <= 6 when rst = '1' else
		      0 when num_clks = 6 else
		      ((start_choice + end_choice) / 2) mod 6 when start_choice <= end_choice else
		      ((start_choice + end_choice + 6) / 2) mod 6;

	qtemp <= "00000000" when rst = '1' or 
		 		(clk_choice < 0 or clk_choice > 5) or train_en = '0' else
	       to_stdlogicvector(to_bitvector(internal(clk_choice)) rol shift_sel(clk_choice)) (9 downto 2);
	       --internal(clk_choice) (9 downto 2);

	Q <= "00000000" when rst = '1' or (clk_choice < 0 or clk_choice > 5) else
	     qtemp;
	     

	-- Assign locked output based on confidence, which is low unless only
	-- one gap in bits
	locked <= '0' when (rst = '1') or not (num_gaps = 1 and num_clks >= 3) else
		  '1';



end Behavioral;
