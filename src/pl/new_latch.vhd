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


entity new_latch is
	Port ( d1 : in STD_LOGIC;
	       d2 : in STD_LOGIC;
	       d_ctl : in STD_LOGIC;
	       train_en : in STD_LOGIC;
	       pix_clk : in STD_LOGIC;
	       clk : in STD_LOGIC;
	       rst : in STD_LOGIC;
	       out_latch : out STD_LOGIC := '0';
	       locked : out STD_LOGIC := '0';
	       q1 : out STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
	       q2 : out STD_LOGIC_VECTOR (7 downto 0) := (others => '0'));
end new_latch;

architecture Behavioral of new_latch is


	------ External component declarations ------

	component DDRlatch is
		Port ( d : in STD_LOGIC;
		       latch : in STD_LOGIC;
		       clk : in STD_LOGIC;
		       rst : in STD_LOGIC;
		       q : out STD_LOGIC_VECTOR (9 downto 0));
	end component;

-- 	component pll_wrapper is
-- 		Port ( clk : in STD_LOGIC;
-- 		       rst : in STD_LOGIC;
-- 		       clk_out : out STD_LOGIC_VECTOR ( 5 downto 0 );
-- 		       locked : out STD_LOGIC);
-- 	end component;
-- 
-- 	component match is
-- 		Port ( test : in STD_LOGIC_VECTOR (9 downto 0);
-- 		       key : in STD_LOGIC_VECTOR (9 downto 0);
-- 		       train_en : in STD_LOGIC;
-- 		       rst : in STD_LOGIC;
-- 		       matched : out STD_LOGIC;
-- 		       shifted : out STD_LOGIC_VECTOR (9 downto 0);
-- 		       shift : out INTEGER);
-- 	end component;
-- 
-- 	component clock_select is
-- 		Port ( clk_sel : in STD_LOGIC_VECTOR (5 downto 0);
-- 		       train_en : in STD_LOGIC;
-- 		       rst : in STD_LOGIC;
-- 		       chosen : out integer;
-- 		       confident : out STD_LOGIC);
-- 	end component;

	component DDRshift is
		Generic ( bits : integer);
		Port ( d : in STD_LOGIC;
		       clk : in STD_LOGIC;
		       rst : in STD_LOGIC;
		       q : out STD_LOGIC_VECTOR ((bits-1) downto 0));
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

	signal int_q1, int_q2, int_ctl : std_logic_vector (59 downto 0);
	signal offset1, offset2, offset_ctl : integer := 0;
	signal int_train : boolean := false;

begin

	-- Instances of the DDRshift component
	D1_INST : DDRshift 
		generic map (bits => 30)
		port map (d => d1,
			  clk => clk,
			  rst => rst,
			  q => int_q1);

	D2_INST : DDRshift 
		generic map (bits => 30)
		port map (d => d2,
			  clk => clk,
			  rst => rst,
			  q => int_q2);

	CTL_INST : DDRshift 
		generic map (bits => 30)
		port map (d => d_ctl,
			  clk => clk,
			  rst => rst,
			  q => int_ctl);

	FRAMING : process(pix_clk, rst)
		variable pos1, pos2, pos_ctl : integer;
		variable diff_1_2, diff_1_ctl, diff_2_ctl : integer;
		variable dval, fval, lval : std_logic;
	begin

		if rst = '1' then

			-- Pixel delineation/framing
			pos1 := -1;
			pos2 := -1;
			pos_ctl := -1;
			offset1 <= 0;
			offset2 <= 0;
			offset_ctl <= 0;

			-- Control bits
			dval := '0';
			fval := '0';
			lval := '0';

			-- Output signals
			q1 <= (others => '0');
			q2 <= (others => '0');
			out_latch <= '0';

		-- Rising edge of pix_clk
		elsif pix_clk'EVENT and pix_clk = '1' then

			if int_train then

				-- Reset position variables
				pos1 := -1;
				pos2 := -1;
				pos_ctl := -1;

				-- Determine framing for each signal
				for I in 0 to 9 loop
					if int_q1((I+9) downto I) = "0001010101" then
						pos1 := I;
					end if;
					if int_q2((I+9) downto I) = "0001010101" then
						pos2 := I;
					end if;
					if int_ctl((I+9) downto I) = "1000000000" then
						pos_ctl := I;
					end if;
				end loop;

				-- Determine if positioning would be closer at a
				-- different offset
				if pos1 /= -1 and pos2 /= -1 then
					diff_1_2 := pos1 - pos2;
					if diff_1_2 < 0 then
						diff_1_2 := 0-diff_1_2;
					end if;
				else
					diff_1_2 := -1;
				end if;
				if pos1 /= -1 and pos_ctl /= -1 then
					diff_1_ctl := pos1 - pos_ctl;
					if diff_1_ctl < 0 then
						diff_1_ctl := 0-diff_1_ctl;
					end if;
				else
					diff_1_ctl := -1;
				end if;
				if pos2 /= -1 and pos_ctl /= -1 then
					diff_2_ctl := pos2 - pos_ctl;
					if diff_2_ctl < 0 then
						diff_2_ctl := 0-diff_2_ctl;
					end if;
				else
					diff_2_ctl := -1;
				end if;

				if diff_1_2 > 5 then
					if pos1 < pos2 then pos1 := pos1 + 10;
					else pos2 := pos2 + 10;
					end if;
				end if;
				if diff_1_ctl > 5 then
					if pos1 < pos_ctl then pos1 := pos1 + 10;
					else pos_ctl := pos_ctl + 10;
					end if;
				end if;
				if diff_2_ctl > 5 then
					if pos2 < pos_ctl then pos_ctl := pos_ctl + 10;
					else pos_ctl := pos_ctl + 10;
					end if;
				end if;

				-- If match was found for the variable, transfer
				-- that to the global signal
				if pos1 /= -1 then
					offset1 <= pos1;
				end if;
				if pos2 /= -1 then
					offset2 <= pos2;
				end if;
				if pos_ctl /= -1 then
					offset_ctl <= pos_ctl;
				end if;

				-- Assume good lock if all positions could be determined
				if pos1 /= -1 and pos2 /= -1 and pos_ctl /= -1 then
					locked <= '1';
					int_train <= false;
				end if;

				-- While training, output zeros
-- 				q1 <= (others => '0');
-- 				q2 <= (others => '0');
				q1 <= int_q1((pos1+9) downto (pos1+2));
				q2 <= int_q2((pos2+9) downto (pos2+2));

			else -- int_train

				-- Parse the bits of the control channel 
				dval <= int_ctl(pos_ctl+0);
				fval <= int_ctl(pos_ctl+2);
				lval <= int_ctl(pos_ctl+1);

				-- If valid data, send to output and set output
				-- latch
				if dval = '1' then
					q1 <= int_q1((pos1+9) downto (pos1+2));
					q2 <= int_q2((pos2+9) downto (pos2+2));
					out_latch <= '1';
				end if; -- dval

			end if; -- int_train

		-- Falling edge of pix_clk
		elsif pix_clk'EVENT and pix_clk = '0' then

			-- Reset output latch if it has been set
			out_latch <= '0';

		end if; -- rst/pix_clk

	end process; -- FRAMING

	TRAIN_PROC : process (train_en)
	begin
		if train_en'EVENT and train_en = '1' then
			int_train <= true;
		elsif train_en'EVENT and train_en = '0' then
			int_train <= false;
		end if;
	end process; -- TRAIN_PROC


-- 	-- Inverted clock
-- 	inv_clk <= '0' when rst = '1' else
-- 		   not clk;
-- 
-- 
-- 	-- Clock phase generating PLL block. Wrapper around block design
-- 	PLL_INST : pll_wrapper port map(clk => clk,
-- 					rst => rst,
-- 					clk_out => phase_clk,
-- 					locked => pll_locked);
-- 
-- 	-- Setup six ten-bit latched DDR shift registers (from DDRlatch.vhd)
-- 	SHIFT_CHANNELS : for I in 0 to 5 generate
-- 
-- 		-- A single data line
-- 		SHIFT_GEN : DDRlatch port map(d => d,
-- 					      clk => phase_clk(I),
-- 					      rst => rst,
-- 					      latch => int_latch,
-- 					      q => internal(I));
-- 
-- 	end generate SHIFT_CHANNELS;
-- 
-- 
-- 	-- Count to ten on the DDR clock and set the internal latch, then
-- 	-- check the internal signals to see if they match the training
-- 	-- data
-- 	COUNT_PROC : process(clk, inv_clk, rst)
-- 
-- 		-- Counter variable, initialize to 0
-- 		variable count : integer := 0;
-- 
-- 	begin
-- 
-- 		-- Check reset signal, set all signals to 0
-- 		if rst = '0' then
-- 
-- 			-- Check for rising or falling edge (rising on inv_clk
-- 			if rising_edge(clk) or rising_edge(inv_clk) then
-- 
-- 				-- Increment counter
-- 				count := count + 1;
-- 
-- 				-- If latch is set, reset it
-- 				if(clk = '1' and int_latch = '1') then
-- 					int_latch <= '0';
-- 				end if;
-- 
-- 				-- If count reached 10, set internal latch
-- 				if(count >= 10) then
-- 					if(clk = '1') then
-- 						int_latch <= '1';
-- 					end if;
-- 					count := 0;
-- 				end if;
-- 
-- 			end if; -- DDR edge detector
-- 
-- 		else
-- 
-- 			int_latch <= '0';
-- 			out_latch <= '0';
-- 			count := 0;
-- 
-- 		end if; -- rst
-- 
-- 	end process; -- COUNT_PROC
-- 
-- 
-- 	-- Generate the training data comparison blocks
-- 	COMPARE : for I in 0 to 5 generate
-- 
-- 		SHIFT_COMPARE : match port map (test => internal(I),
-- 						key => train,
-- 						train_en => train_en,
-- 						rst => rst,
-- 						matched => clk_sel(I),
-- 						shifted => internal_shifted(I),
-- 						shift => shift_sel(I));
-- 
-- 	end generate COMPARE;
-- 
-- 
-- 	-- Select the right clock based on the value of clk_sel
-- 	FINAL_SELECTION : clock_select port map (clk_sel => clk_sel,
-- 						 train_en => train_en,
-- 						 rst => rst,
-- 						 chosen => clk_choice,
-- 						 confident => locked);
-- 
-- 
-- 	-- Assign output to the properly selected and shifted input phase
-- 	qtemp <= (others => '0') when rst = '1' or (clk_choice < 0 or clk_choice > 5) else
-- 		 internal_shifted(clk_choice);
-- 		 -- to_stdlogicvector(to_bitvector(internal(clk_choice)) rol conv_integer(shift_sel(clk_choice)));
-- 
-- 	-- Trim the 2 LSBs for the final latched output
-- 	q <= (others => '0') when rst = '1' else
-- 	     qtemp (9 downto 2);

end Behavioral;
