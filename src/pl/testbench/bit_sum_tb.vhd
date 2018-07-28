------------------------------------------------------------------------------
-- File:
--	bit_sum_tb.vhd
--
-- Description:
--	Test bench for the bit_sum circuit
--
-- Author:
--	David Stockhouse
--
-- Revision 1.0
-- Last edited: 7/11/18
------------------------------------------------------------------------------

use std.textio.all;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bit_sum_tb is
end bit_sum_tb;

architecture Behavioral of bit_sum_tb is

 	component bit_sum is
 		Generic ( n : INTEGER := 6);
 		Port ( bits : in STD_LOGIC_VECTOR ((n-1) downto 0);
 		       rst : in STD_LOGIC;
 		       count : out INTEGER);
 	end component;
 
 	signal int_bits : STD_LOGIC_VECTOR(5 downto 0) := (others => '0');
 	signal int_rst : STD_LOGIC := '1';
 	signal int_count : INTEGER;

begin

	INST : bit_sum port map (bits => int_bits,
				 rst => int_rst,
				 count => int_count);

	process
		variable l : line;
	begin

		write (l, String'("Started bit_sum_tb"));
		writeline (output, l);

		wait for 10 ns;

		int_rst <= '0';

		wait for 10 ns;

		int_bits <= "101101";

		write (l, int_bits);
		writeline(output, l);

		wait for 10 ns;

		write (l, int_count);
		writeline(output, l);

		wait for 10 ns;

		int_bits <= "001101";

		write (l, int_bits);
		writeline(output, l);

		wait for 10 ns;

		write (l, int_count);
		writeline(output, l);

		wait for 10 ns;

		int_bits <= "011001";

		write (l, int_bits);
		writeline(output, l);

		wait for 10 ns;

		write (l, int_count);
		writeline(output, l);

		wait for 10 ns;

		int_bits <= "100011";

		write (l, int_bits);
		writeline(output, l);

		wait for 10 ns;

		write (l, int_count);
		writeline(output, l);

		wait for 10 ns;

		int_bits <= "001100";

		write (l, int_bits);
		writeline(output, l);

		wait for 10 ns;

		write (l, int_count);
		writeline(output, l);


		-- TEST_LOOP : for I in 0 to (2**6-1) loop


		wait;

	end process;

end Behavioral;
