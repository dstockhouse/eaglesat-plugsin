------------------------------------------------------------------------------
-- File:
--	interface_tb.vhd
--
-- Description:
--	Test bench for the CMV2000 interface
--
-- Author:
--	David Stockhouse
--
-- Revision 1.0
-- Last edited: 7/28/18
------------------------------------------------------------------------------

use STD.TEXTIO.ALL;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity interface_tb is
end interface_tb;

architecture Behavioral of interface_tb is
 
	component new_latch is
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
	end component;

	signal d1, d2, d_ctl, clk, pix_clk, rst, latch, train_en, locked : STD_LOGIC;
	signal q1, q2 : STD_LOGIC_VECTOR (7 downto 0);
	signal train_seq : STD_LOGIC_VECTOR (9 downto 0) := "0001010101";

begin

	TEST_INS : new_latch port map (d1 => d1,
				       d2 => d2,
				       d_ctl => d_ctl,
				       train_en => train_en,
				       pix_clk => pix_clk,
				       clk => clk,
				       rst => rst,
				       out_latch => latch,
				       locked => locked,
				       q1 => q1,
				       q2 => q2);

	process
		variable l : line;
		variable data, ctl : STD_LOGIC_VECTOR (9 downto 0);
	begin

		rst <= '1';
		d1 <= '0';
		d2 <= '0';
		d_ctl <= '0';
		pix_clk <= '0';
		clk <= '0';

		write (l, String'("Started interface_tb"));
		writeline (output, l);
		write (l, String'(""));
		writeline (output, l);

		wait for 10 ns;

		rst <= '0';
		train_en <= '1';

		wait for 10 ns;

		data := train_seq;
		ctl := "1000000000";

		OUTER_LOOP : for J in 0 to 5 loop

			pix_clk <= '1';

			FIRST_LOOP : for I in 0 to 9 loop
				d1 <= data(I);
				d2 <= data(I);
				d_ctl <= ctl(I);
				wait for 5 ns;

				clk <= not clk;
				wait for 5 ns;

				if I = 5 then
					pix_clk <= '0';
				end if;

			end loop; -- FIRST_LOOP

			write (l, q1);
			writeline(output, l);
			write (l, q2);
			writeline(output, l);

		end loop; -- OUTER_LOOP

		train_en <= '0';

		data := "1110011000";
		ctl := "1000000111";

		pix_clk <= '1';

		SECOND_LOOP : for I in 0 to 9 loop
			d1 <= data(I);
			d2 <= data(I);
			d_ctl <= ctl(I);
			wait for 5 ns;

			clk <= not clk;
			wait for 5 ns;

				if I = 5 then
					pix_clk <= '0';
				end if;

		end loop; -- SECOND_LOOP

		write (l, String'("Input:"));
		writeline (output, l);

		write (l, data);
		writeline(output, l);

		write (l, String'("Output:"));
		writeline (output, l);

		write (l, q1);
		writeline(output, l);
		write (l, q2);
		writeline(output, l);



		wait;

	end process;

end Behavioral;
