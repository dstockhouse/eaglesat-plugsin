------------------------------------------------------------------------------
-- File:
--	bit_sum.vhd
--
-- Description:
--	Counts the number of input 1's
--
-- Author:
--	David Stockhouse
--
-- Revision 1.0
-- Last edited: 7/03/18
------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.NUMERIC_STD.ALL;


entity bit_sum is
	Port ( bits : in STD_LOGIC_VECTOR (5 downto 0);
	       rst : in STD_LOGIC;
	       count : out integer);
end bit_sum;


architecture Behavioral of bit_sum is

begin

	-- Count up all the bits
	count <= 0 when rst = '1' else
		 conv_integer(bits(0)) + 
		 conv_integer(bits(1)) +
		 conv_integer(bits(2)) +
		 conv_integer(bits(3)) +
		 conv_integer(bits(4)) +
		 conv_integer(bits(5));

end Behavioral;
