------------------------------------------------------------------------------
-- File:
--	clock_select.vhd
--
-- Description:
--	Takes in the 6 wide clk_sel vector from interface.vhd and selects the 
--	proper clock to use for shifting in data.
--
-- Author:
--	David Stockhouse
--
-- Revision 1.2
-- Last edited: 7/03/18
------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clock_select is
	Port ( clk_sel : in STD_LOGIC_VECTOR (5 downto 0);
	       train_en : in STD_LOGIC;
	       rst : in STD_LOGIC;
	       chosen : out integer;
	       confident : out STD_LOGIC);
end clock_select;

architecture Behavioral of clock_select is

	------ External Component Declarations ------

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

	------ Internal Signal Declarations ------
 
 	signal gap_rst : std_logic;
 
 	signal num_gaps, num_clks : integer;
 
	-- measurement contains a measure of likelihood that each bit of
	-- clk_sel is the center of correct bits
	type meas is array (0 to 5) of integer;
	signal measurement : meas;

begin

	-- Count the number of on bits
	COUNT : bit_sum port map (bits => clk_sel,
				  rst => rst,
				  count => num_clks);


	-- Determine the measure of likelihood for each bit
	-- Enumerating all of the possibilities of configurations isn't ideal,
	-- but I couldn't think of more elegant ways to do it
	-- All indexing arithmetic is mod 6 so that it will be treated like a 
	-- ring buffer, which it is
	--
	-- The highest likelihood is given to a 1 in the center of a group of 5
	--	Ex. (011111) bit 2 is chosen
	-- Next is the center of a group of 4, with both centers given the same
	-- measurement so the first numerically will be chosen later
	--	Ex. (100111) bits 0 and 1 are both equally likely
	-- Next is the center of a group of 3 surrounded by 0's. If there is a
	-- 1 in the opposite bit of the center it won't change the likelihood.
	-- Having the additional gap will affect the confidence however.
	--	Ex. (000111 or 010111) bit 1 is chosen in both cases. 
	-- Next is the case of a group of three with a gap between. The center
	-- most bit is chosen. This category also catches two groups of 2
	-- evenly spaced, all with equal likelihood. This is a low confidence 
	-- arrangement
	--	Ex. (010110) bit 2 is chosen
	-- Next is a group of 2 not in one of the earlier categories
	--	Ex. (000110) bits 1 and 2 are both equally likely
	-- Next is any lone 1 surrounded on both sides by 0's. 
	-- And if the indexed bit itself is not set, it has a likelihood of 0
	MEASURE : for I in 0 to 5 generate

		measurement(I) <= 0 when rst = '1' else
				  -- Center of a block of 5
				  6 when clk_sel(I) = '1'
				  and (clk_sel((I-1) mod 6) = '1'
				  and clk_sel((I+1) mod 6) = '1'
				  and clk_sel((I-2) mod 6) = '1'
				  and clk_sel((I+2) mod 6) = '1')
			  else
				  -- Center of a block of 4. In this case two
				  -- centers are both equally likely
				  5 when clk_sel(I) = '1'
				  and (clk_sel((I-1) mod 6) = '1'
				  and clk_sel((I+1) mod 6) = '1'
				  and ((clk_sel((I-2) mod 6) = '1'
				  and clk_sel((I+2) mod 6) = '0')
				  or (clk_sel((I-2) mod 6) = '0'
				  and clk_sel((I+2) mod 6) = '1')))
			  else
				  -- Center of a block of 3
				  4 when clk_sel(I) = '1'
				  and (clk_sel((I-1) mod 6) = '1'
				  and clk_sel((I+1) mod 6) = '1'
				  and clk_sel((I-2) mod 6) = '0'
				  and clk_sel((I+2) mod 6) = '0')
			  else
				  -- Center of 3 with a gap between
				  3 when clk_sel(I) = '1'
				  and ((clk_sel((I-1) mod 6) = '0'
				  and clk_sel((I+1) mod 6) = '1'
				  and clk_sel((I-2) mod 6) = '1'
				  and clk_sel((I+2) mod 6) = '0')
				  or (clk_sel((I-1) mod 6) = '1'
				  and clk_sel((I+1) mod 6) = '0'
				  and clk_sel((I-2) mod 6) = '0'
				  and clk_sel((I+2) mod 6) = '0'))
			  else
				  -- Just 2 side by side
				  2 when clk_sel(I) = '1'
				  and ((clk_sel((I-1) mod 6) = '0'
				  and clk_sel((I+1) mod 6) = '1'
				  and clk_sel((I-2) mod 6) = '0'
				  and clk_sel((I+2) mod 6) = '0')
				  or (clk_sel((I-1) mod 6) = '1'
				  and clk_sel((I+1) mod 6) = '0'
				  and clk_sel((I-2) mod 6) = '0'
				  and clk_sel((I+2) mod 6) = '0'))
			  else
				  -- Single set bit
				  1 when clk_sel(I) = '1' 
				  and (clk_sel((I-1) mod 6) = '0' 
				  and clk_sel((I+1) mod 6) = '0')
			  else
				  -- Default
				  0;

	end generate MEASURE;

	-- Doing this in a process is also not ideal, but it's the simplest way
	-- to guarantee nothing is multiply driven
	MEASURE_PROC : process (measurement, num_gaps)
		variable highest : integer := 0;
	begin

		-- Find the highest confidence number in clk_sel. If multiple
		-- positions have the same measurement, the lowest numeric
		-- index is selected because at that point it may as well be
		-- an arbitrary choice
		CHOICE_LOOP : for I in 0 to 5 loop

			if measurement(I) > measurement(highest) then
				highest := I;
			end if;

		end loop CHOICE_LOOP;

		if num_gaps = 0 then
			-- Handles the case where all 6 bits are set. This may be the case
			chosen <= 1;
			confident <= '0';
		else
			chosen <= highest;
			if highest > 3 then
				confident <= '1';
			else
				confident <= '0';
			end if;

		end if;

	end process; -- MEASURE_PROC

 	-- Count the gaps between 1's in clk_sel
 	gap_rst <= rst or (not train_en);
 	GAPS : gap_counter port map (bits => clk_sel,
 				     rst => gap_rst,
 				     count => num_gaps);


end Behavioral;
