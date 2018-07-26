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
-- Revision 1.1
-- Last edited: 7/10/18
------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;


entity bit_sum is
	Generic ( n : integer := 6);
	Port ( bits : in STD_LOGIC_VECTOR ((n-1) downto 0);
	       rst : in STD_LOGIC;
	       count : out integer);
end bit_sum;


architecture Behavioral of bit_sum is

begin

	-- Count up all the bits
	COUNT_PROC : process(bits, rst)
		variable temp : integer := 0;
	begin
		if rst = '1' then
			count <= 0;
		else
			temp := 0;
			COUNT_LOOP : for i in 0 to (n - 1) loop
				temp := temp + conv_integer(bits(i));
			end loop; -- COUNT_LOOP
			count <= temp;
		end if; -- rst
	end process; -- COUNT_PROC

end Behavioral;
