------------------------------------------------------------------------------
-- File:
--	DDRshift_tb.vhd
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
use ieee.STD_LOGIC_TEXTIO.ALL;

entity DDRshift_tb is
end DDRshift_tb;

architecture Behavioral of DDRshift_tb is

	component DDRshift is
		Generic ( bits : integer);
		Port ( d : in STD_LOGIC;
		       clk : in STD_LOGIC;
		       rst : in STD_LOGIC;
		       q : out STD_LOGIC_VECTOR ((bits-1) downto 0));
	end component;
 
	signal d, clk, rst, latch : STD_LOGIC;
	signal q : STD_LOGIC_VECTOR (29 downto 0) := (others => '1');

begin

	TEST_INS : DDRshift 
		generic map ( bits => 30)
		port map (d => d,
			  clk => clk,
			  rst => rst,
			  q => q);

	process
		variable l : line;
		variable data : STD_LOGIC_VECTOR (9 downto 0);
	begin

		rst <= '1';
		d <= '0';
		clk <= '0';

		write (l, String'("Started DDRshift_tb"));
		writeline (output, l);
		write (l, String'(""));
		writeline (output, l);

		wait for 10 ns;

		rst <= '0';

		wait for 10 ns;

		data := "0001010101";

		write (l, String'("Input:"));
		writeline (output, l);

		write (l, data);
		writeline(output, l);

		write (l, String'("Output:"));
		writeline (output, l);

		FIRST_LOOP : for I in 0 to 9 loop
			d <= data(I);
			wait for 5 ns;

			write (l, d);
			writeline(output, l);

			clk <= not clk;
			wait for 5 ns;

			write (l, q);
			writeline(output, l);

		end loop; -- FIRST_LOOP


		wait;

	end process;

end Behavioral;
