------------------------------------------------------------------------------
-- File:
--	DDRlatch.vhd
--
-- Description:
--	An implementation of the 10-bit DDR shift register that takes a latch
--	signal input. When the latch is set, the data that has been shifted in
-- 	is stored on a 10-bit register buffer so it can be read while the next
--	10 bits are being shifted in
--
-- Author:
--	David Stockhouse & Sam Janoff
--
-- Revision 1.2
-- Last edited: 6/10/18
------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity DDRlatch is
	Port ( D : in STD_LOGIC;
	       clk : in STD_LOGIC;
	       rst : in STD_LOGIC;
	       latch : in STD_LOGIC;
	       Q : out STD_LOGIC_VECTOR (9 downto 0) := (others => '0'));
end DDRlatch;

architecture Behavioral of DDRlatch is

	component DDRshift is
		Port ( D : in STD_LOGIC;
		       clk : in STD_LOGIC;
		       rst : in STD_LOGIC;
		       Q : out STD_LOGIC_VECTOR (9 downto 0));
	end component;

	-- Internal signal between the output of the SR and input of buffer
	signal internal : STD_LOGIC_VECTOR (9 downto 0) := (others => '0');

begin

	-- Generate buffer
	Q <= internal when rising_edge(latch);

	-- Generate DDR shift register
	SHIFT_GEN : DDRshift port map (D => D,
	                               clk => clk,
	                               rst => rst, 
	                               Q => internal);

end Behavioral;
