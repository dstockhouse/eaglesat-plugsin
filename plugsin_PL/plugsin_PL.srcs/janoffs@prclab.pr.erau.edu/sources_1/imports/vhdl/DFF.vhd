------------------------------------------------------------------------------
-- File:
--	DFF.vhd
--
-- Description:
--	A D flip flop, rising edge triggered
--
-- Author:
--	David Stockhouse & Sam Janoff
--
-- Revision 1.1
-- Last edited: 3/4/18
------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity DFF is
	Port ( D : in STD_LOGIC;
	       clk : in STD_LOGIC;
	       rst: in STD_LOGIC;
	       Q : out STD_LOGIC);
end DFF;

architecture Behavioral of DFF is

begin

	-- Latch input to output
	LATCH_PROC : process(clk, rst)
	begin
		-- Check rst
		if rst = '1' then
			Q <= '0';
		elsif clk'EVENT and clk='1' then
			-- Rising edge of clk
			Q <= D;
		end if;

	end process; -- LATCH_PROC

end Behavioral;
