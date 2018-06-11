------------------------------------------------------------------------------
-- File:
--	interface_tb.vhd
--
-- Description:
--	This is a testbench for the interface.vhd module meant to simulate
--	signals from the CMV2000
--
-- Author:
--	David Stockhouse
--
-- Revision 1.1
-- Last edited: 3/9/18
------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;


entity tb is
--  Port ( );
end tb;

architecture Behavioral of tb is

	component interface is
		Port ( D : in STD_LOGIC;
		       rst : in STD_LOGIC;
		       clk : in STD_LOGIC;
		       pix_clk : in STD_LOGIC;
		       train_en : in STD_LOGIC;
		       train : in STD_LOGIC_VECTOR (9 downto 0);
		       latch_sig : out STD_LOGIC := '0';
		       locked : out STD_LOGIC := '0';
		       Q : out STD_LOGIC_VECTOR (7 downto 0));
	end component;

	signal D, rst, clk, pix_clk, train_en, latch_sig, locked : STD_LOGIC := '0';
	signal train : STD_LOGIC_VECTOR (9 downto 0);
	signal Q : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');

begin

	-- Instantiate interface
	INSTANCE : interface port map (D => D,
				       rst => rst,
				       clk => clk,
				       pix_clk => pix_clk,
				       train_en => train_en,
				       train => train,
				       latch_sig => latch_sig,
				       locked => locked,
				       Q => Q);


	-- Training sequence is constant
	train <= "0001010101";

	-- Clock period 20ns
	clk <= not clk after 20ns;


	process
	begin

		-- Ensure everything is reset
		rst <= '1';

		wait for 1000ns;

		rst <= '0';

		wait for 2000ns;


		-- Enable training
		train_en <= '1';


		-- Loop the training sequence into the serial line
		TRAINING : for I in 0 to 20 loop

			D <= '1';
			wait for 10ns;
			D <= '0';
			wait for 10ns;
			D <= '1';
			wait for 10ns;
			D <= '0';
			wait for 10ns;
			D <= '1';
			wait for 10ns;
			D <= '0';
			wait for 10ns;
			D <= '1';
			wait for 10ns;
			D <= '0';
			wait for 30ns;

		end loop; -- TRAINING
		

		-- Stop execution
		wait;

	end process;

end Behavioral;
