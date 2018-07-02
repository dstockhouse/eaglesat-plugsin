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
-- Revision 1.1
-- Last edited: 4/02/18
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
 
	-- /measurement/ contains a measure of likelihood that each bit of
	-- /clk_sel/ is the center of correct bits
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
	MEASURE : for I in 0 to 5 generate

		measurement(I) <= 1 when clk_sel(I) = '1' 
				  and (clk_sel((I-1) mod 6) = '0' 
				  and clk_sel((I+1) mod 6) = '0')
			  	  else
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
				  4 when clk_sel(I) = '1'
				  and (clk_sel((I-1) mod 6) = '1'
				  and clk_sel((I+1) mod 6) = '1'
				  and clk_sel((I-2) mod 6) = '0'
				  and clk_sel((I+2) mod 6) = '0')
			  	  else
				  -- Block of 4
				  5 when clk_sel(I) = '1'
				  and (clk_sel((I-1) mod 6) = '1'
				  and clk_sel((I+1) mod 6) = '1'
				  and ((clk_sel((I-2) mod 6) = '1'
				  and clk_sel((I+2) mod 6) = '0')
				  or (clk_sel((I-2) mod 6) = '0'
				  and clk_sel((I+2) mod 6) = '1'))
			  	  else
				  -- Center of a block of 5 (Ex. 011111)
				  6 when clk_sel(I) = '1'
				  and (clk_sel((I-1) mod 6) = '1'
				  and clk_sel((I+1) mod 6) = '1'
				  and clk_sel((I-2) mod 6) = '1'
				  and clk_sel((I+2) mod 6) = '1')
			  	  else
				  0;

	end generate MEASURE;

	MEASURE_PROC : process (measurement, num_gaps)
		variable highest : integer := 0;
	begin

		CHOICE_LOOP : for I in 0 to 5 loop

			if measurement(I) > measurement(highest) then
				highest := I;
			end if;

		end loop CHOICE_LOOP;

-- 		if num_gaps = 1 and num_clks > 2 then
-- 			confident <= '1';
-- 		else 
-- 			confident <= '0';
-- 		end if;

		if num_gaps = 0 then
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
