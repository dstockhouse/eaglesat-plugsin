------------------------------------------------------------------------------
-- File:
--	gap_counter.vhd
--
-- Description:
--	Counts the gaps between 1's in a 6-bit word
--
--	For example:
--		110100 has 2 gaps
--		011100 has 1 gap
--
-- Author:
--	David Stockhouse & Sam Janoff
--
-- Revision 1.0
-- Last edited: 3/5/18
------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.NUMERIC_STD.ALL;


entity gap_counter is
    Port ( bits : in STD_LOGIC_VECTOR (5 downto 0);
    	   rst : in STD_LOGIC;
           count : out integer);
end gap_counter;

architecture Behavioral of gap_counter is

	component bit_sum is
		Port ( bits : in STD_LOGIC_VECTOR (5 downto 0);
		       rst : in STD_LOGIC;
		       count : out integer);
	end component;

	signal int_gaps : std_logic_vector (5 downto 0);

begin

	COUNTER : bit_sum port map (bits => int_gaps,
				    rst => rst,
				    count => count);

	int_gaps(0) <= '0' when rst = '1' else
		       '1' when (bits(0) = '1' and bits(5) = '0') else
		       '0';

	GAP_GEN : for I in 1 to 5 generate
		int_gaps(I) <= '0' when rst = '1' else
			       '1' when (bits(I) = '1') and
			       (bits((I - 1) mod 6) = '0') else
			       '0';
	end generate GAP_GEN;

end Behavioral;
