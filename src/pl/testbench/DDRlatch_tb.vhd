------------------------------------------------------------------------------
-- File:
--	DDRlatch_tb.vhd
--
-- Description:
--	Test bench for the DDR shift-in circuitry
--
-- Author:
--	David Stockhouse
--
-- Revision 1.0
-- Last edited: 7/26/18
------------------------------------------------------------------------------

use std.textio.all;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DDRlatch_tb is
end DDRlatch_tb;

architecture Behavioral of DDRlatch_tb is

 	component DDRlatch is
		Port ( d : in STD_LOGIC;
		       clk : in STD_LOGIC;
		       rst : in STD_LOGIC;
		       latch : out STD_LOGIC;
		       q : out STD_LOGIC_VECTOR (9 downto 0) := (others => '0'));
 	end component;
 
	signal d, clk, rst, latch : STD_LOGIC;
	signal q : STD_LOGIC_VECTOR (9 downto 0);

begin

	TEST_INS : DDRlatch port map (d => d,
				      clk => clk,
				      rst => rst,
				      latch => latch,
				      q => q);

	process
		variable l : line;
		variable data : STD_LOGIC_VECTOR (9 downto 0);
	begin

		rst <= '1';
		d <= '0';
		clk <= '0';

		write (l, String'("Started DDRlatch_tb"));
		writeline (output, l);
		write (l, String'(""));
		writeline (output, l);

		wait for 10 ns;

		int_rst <= '0';

		wait for 10 ns;

		data := "1111100000";

		FIRST_LOOP for I in 0 to 9 loop
			d <= data(I);
			wait for 5 ns;

			clk <= not clk;
			wait for 5 ns;
		end for; -- FIRST_LOOP

		write (l, String'("Input:"));
		writeline (output, l);

		write (l, data);
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
