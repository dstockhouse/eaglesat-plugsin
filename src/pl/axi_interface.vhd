------------------------------------------------------------------------------
-- File:
--	axi_interface.vhd
--
-- Description:
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
end new_latch;

architecture Behavioral of new_latch is


	------ External component declarations ------

	component DDRshift is
		Generic ( bits : integer);
		Port ( d : in STD_LOGIC;
		       clk : in STD_LOGIC;
		       rst : in STD_LOGIC;
		       q : out STD_LOGIC_VECTOR ((bits-1) downto 0));
	end component;



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

begin

	-- Instances of the DDRshift component
	D1_INST : DDRshift 
		generic map (bits => 30)
		port map (d => d1,
			  clk => clk,
			  rst => ddr_rst,
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

	ddr_rst <= rst;
	-- ddr_rst <= rst or clr;


	-- Process to determine where the correct position of each pixel data in
	-- the longer buffer whenever the pixel clock rising edge occurs
	FRAMING : process(train_en, pix_clk, rst)

		-- Starting positions in each buffer
		variable pos1, pos2, pos_ctl : integer;
		-- Difference between positions to determine whether to
		-- reposition certain signals
		variable diff_1_2, diff_1_ctl, diff_2_ctl : integer;
		-- Bits in the control channel
		variable dval, fval, lval : std_logic;
		-- Flag if train_en has switched
		variable train_swap : std_logic;

	begin

		if rst = '1' then -- Reset signals and variables

			-- Pixel delineation/framing
			pos1 := -1;
			pos2 := -1;
			pos_ctl := -1;
			offset1 <= 2; -- Init to 2 for expected DDRblock delay
			offset2 <= 2;
			offset_ctl <= 2;

			-- Control bit variables
			dval := '0';
			fval := '0';
			lval := '0';

			-- Output signals
			q1 <= (others => '0');
			q2 <= (others => '0');
			out_latch <= '0';

		elsif clr = '1' then -- Clear buffer and output

			-- Control bit variables
			dval := '0';
			fval := '0';
			lval := '0';

			-- Output signals
			q1 <= (others => '0');
			q2 <= (others => '0');
			out_latch <= '0';

		else

			-- The int_train signal is set within the same process
			-- to avoid having it be multiply driven. The process
			-- only allows one assignment of each signal. In the 
			-- unlikely event that the pix_clk rises at the same
			-- time as train_en changes, the train_en will take
			-- precedence
			train_swap := '0';

			-- Rising edge of train_en
			if train_en'EVENT and train_en = '1' then

				int_train <= '1';
				train_swap := '1';

			end if;

			-- Falling edge of train_en
			if train_en'EVENT and train_en = '0' then

				int_train <= '0';
				train_swap := '1';

			end if;

			-- Rising edge of pix_clk
			if pix_clk'EVENT and pix_clk = '1' then

				if int_train = '1' then

					-- Reset position variables so it can be
					-- determined whether or not they have been
					-- properly set later
					pos1 := -1;
					pos2 := -1;
					pos_ctl := -1;

					-- Determine first possible frame for each signal
					INIT_FRAME_LOOP : for I in 0 to 9 loop
						-- Test each signal buffer against its
						-- training sequence
						if int_q1((I+9) downto I) = "0001010101" then
							pos1 := I;
						end if;
						if int_q2((I+9) downto I) = "0001010101" then
							pos2 := I;
						end if;
						if int_ctl((I+9) downto I) = "1000000000" then
							pos_ctl := I;
						end if;
					end loop; -- INIT_FRAME_LOOP

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

						-- Check if train_en had an edge at the same time
						-- If so, that takes precedence
						if train_swap = '0' then
							int_train <= '0';
						end if;

					end if;

					-- While training, output zeros
					q1 <= (others => '0');
					q2 <= (others => '0');

					-- For debugging
					-- q1 <= int_q1((pos1+9) downto (pos1+2));
					-- q2 <= int_q2((pos2+9) downto (pos2+2));

				else -- int_train

					if pos_ctl /= -1 then

						-- Parse the bits of the control channel 
						dval := int_ctl(pos_ctl+0);
						fval := int_ctl(pos_ctl+2);
						lval := int_ctl(pos_ctl+1);

						-- If valid data, send to output and set output
						-- latch
						if dval = '1' then

							q1 <= int_q1((pos1+9) downto (pos1+2));
							q2 <= int_q2((pos2+9) downto (pos2+2));

							-- Form output words by concatenating bytes
							-- from the input buffer
							-- q1 <= int_q1((pos1+39) downto (pos1+32))
							--       & int_q1((pos1+29) downto (pos1+22))
							--       & int_q1((pos1+19) downto (pos1+12))
							--       & int_q1((pos1+9) downto (pos1+2));

							-- q2 <= int_q2((pos2+39) downto (pos2+32))
							--       & int_q2((pos2+29) downto (pos2+22))
							--       & int_q2((pos2+19) downto (pos2+12))
							--       & int_q2((pos2+9) downto (pos2+2));

							out_latch <= '1';

						end if; -- dval

					end if; -- pos_ctl

				end if; -- int_train

			end if; -- rising edge

			-- Falling edge of pix_clk
			if pix_clk'EVENT and pix_clk = '0' then

				-- Reset output latch if it has been set
				out_latch <= '0';

			end if; -- falling edge

		end if; -- rst

	end process; -- FRAMING

end Behavioral;

