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
-- Revision 1.1
-- Last edited: 3/4/18
------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use IEEE.NUMERIC_STD.ALL;


entity PLL is
	Port ( D1 : in STD_LOGIC;
	       D2 : in STD_LOGIC;
	       CON : in STD_LOGIC;
	       rst : in STD_LOGIC;
	       clk : in STD_LOGIC;
	       latch_sig : out STD_LOGIC := '0';
	       locked : out STD_LOGIC := '0';
	       Q1 : out STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
	       Q2 : out STD_LOGIC_VECTOR (7 downto 0) := (others => '0'));
end PLL;

architecture Behavioral of PLL is

	component DDRlatch is
		Port ( D : in STD_LOGIC;
		       clk : in STD_LOGIC;
		       rst : in STD_LOGIC;
		       latch : in STD_LOGIC;
		       Q : out STD_LOGIC_VECTOR (9 downto 0) := (others => '0'));
	end component;

	-- Training data
	signal train : std_logic_vector(9 downto 0);

	-- Clock signals that are each out of phase a certain amount from the
	-- man clock
	signal phase_clk : std_logic_vector(5 downto 0);

	-- Internal shift register latch signal and inverted clock
	signal int_latch, inv_clk : std_logic;

	-- The type /shifted/ is an array of ten bit vectors representing the
	-- six words shifted in by each phase clock
	type shifted is array (0 to 5) of std_logic_vector (9 downto 0);
	signal int1, int2, intcon : shifted;



	-- /clk_sel/ is a boolean representing which phase clocks have
	-- the correct training data, even if it's shifted a few bits
	signal clk_sel : std_logic_vector(0 to 5);

	-- /num_clks/ keeps track of how many bits in clk_sel are set
	-- /num_gaps/ keeps track of how many gaps between 1's there are
	signal num_clks, num_gaps : integer;

	-- /choice/ is an array of integers that keeps track of which
	-- phased clocks shifted the correct data and if they are
	-- a discrete number of bits out of sync
	type choice is array (0 to 5) of integer;

	-- /shift_sel/ keeps track of how many bits the correctly 
	-- phased clocks are out of sync
	signal shift_sel : choice;

	-- Keep track of which clock phase starts to correctly read
	-- data and which clock phase ends that loop
	signal start_sel, end_sel : integer range (0 to 6);

begin

	-- Training data is constant; the device defaults to 85
	train <= "0001010101";

	-- Inverted clock
	inv_clk <= not clk;


	-- Setup six ten-bit latched DDR shift registers (from DDRlatch.vhd)
	SHIFT6x10 : for I in 0 to 5 generate

		-- First data line
		SHIFT1_GEN : DDRlatch port map(D => D1,
					       clk => pclk(I),
					       rst => rst,
					       latch => int_latch,
					       Q => int1(I));

		-- Second data line
		SHIFT2_GEN : DDRlatch port map(D => D2,
					       clk => pclk(I),
					       rst => rst,
					       latch => int_latch,
					       Q => int2(I));

		-- Control "meta" data line
		SHIFTCON_GEN : DDRlatch port map(D => CON,
						 clk => pclk(I),
						 rst => rst,
						 latch => int_latch,
						 Q => intcon(I));

	end generate SHIFT6x10;


	-- Count to ten on the DDR clock and set the internal latch, then
	-- check the internal signals to see if they match the training
	-- data
	COUNT_PROC : process(clk, inv_clk, rst)

		-- Counter variable, initialize to 0
		variable count : integer;

	begin
		count := 0;

		-- Check reset signal, set all signals to 0
		if(rst = '1') then
			Q1 <= (others => '0');
			Q2 <= (others => '0');
			latch_sig <= '0';
			count := 0;
		else

			-- Check for rising or falling edge (rising on inv_clk
			if((clk'event and clk = '1') or 
			(inv_clk'event and inv_clk = '1'))
			then

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

			end if; -- DDR rising edge

		end if; -- rst else

	end process; -- COUNT_PROC


	-- If internal latch has been set, check shifted data against training
	-- data
	LATCH_PROC : process(int_latch)


	begin

		-- Initialize clock and shift variables to 0
		INIT_LOOP : for I in 0 to 5 loop
			clk_sel(I) := 0;
			shift_sel(I) := 0;
		end loop;

		-- Loop through the phase clocks to find which ones match
		CLOCK_LOOP : for C in 0 to 5 loop
			-- Loop through all 10 bits to see if shifting the 
			-- input from the clocks will make the data line up
			BIT_LOOP : for S in 0 to 9 loop
				-- If it matches the training data, then set
				-- that bit in /clk_sel/ and mark the shift
				-- in shift_sel
				if (int1(C) rol S) = train then
					clk_sel(C) := '1';
					shift_sel(C) := S;
				end if;

			end loop; -- BIT_LOOP

		end loop; -- CLOCK_LOOP


		-- Initialize selection variables to 6 because that would never
		-- be set ordinarily
		start_sel := 6;
		end_sel := 6;
		first := clk_sel(0);
		last := clk_sel(5);

		-- Select centermost clock from all options
		SELECT_LOOP : for I in 0 to 5 loop

			CHECK_COND : if clk_sel(I) = '1' then

				if start_sel = 6 then




					end if;
				end if;



			end loop; -- CHECK_COND

		end loop; -- SELECT_LOOP



	end process; -- LATCH_PROC


	-- Count the bits in clk_sel
	SUM : process(clk_sel)

	begin
		ADD_LOOP : for I in 0 to 5 loop
			if clk_sel(I) = '1' then
				num_clks <= num_clks + 1;
			end if;
		end loop; -- ADD_LOOP

	end process; -- SUM


	CONTINUOUS : process(clk_sel)

		variable started, finished : std_logic;

	begin
		-- Initialize variables to 0
		started := '0';
		finished := '0';

		-- Count gaps
		GAPS : for I in 0 to 5 loop

			if clk_sel(I) = '1' and started = '0' then
				started := '1';
				if I != 0 then
					num_gaps <= num_gaps + 1;
				end if;
			elsif clk_sel(I) = '0' and started = '1' then
				started := '0';
				finished := '1';
			end if;

		end loop; -- GAPS

		if clk_sel(0) = '0' and 


	-- Find the start and end points of the selected clocks
	SELECT_GEN : for I in 0 to 5 generate

		-- Determine if 
		start_sel <= I when (clk_sel(I) = '1') and (


	end generate SELECT_GEN;

end Behavioral;
