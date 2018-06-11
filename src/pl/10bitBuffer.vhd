------------------------------------------------------------------------------
-- File:
--	10bitBuffer.vhd
--
-- Description:
--	A 10-bit register buffer
--
-- Author:
--	David Stockhouse & Sam Janoff
--
-- Revision 1.1
-- Last edited: 3/4/18
------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity bitBuffer is
	Port ( D : in STD_LOGIC_VECTOR (9 downto 0);
	       latch : in STD_LOGIC;
	       rst : in STD_LOGIC;
	       Q : out STD_LOGIC_VECTOR (9 downto 0) := (others => '0'));
end bitBuffer;

architecture Behavioral of bitBuffer is

begin

	-- Route input to output on latch
	Q <= D when rising_edge(latch);


end Behavioral;
