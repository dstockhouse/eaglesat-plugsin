------------------------------------------------------------------------------
-- File:
--	byteBuffer.vhd
--
-- Description:
--	An 8-bit register buffer
--
-- Author:
--	David Stockhouse & Sam Janoff
--
-- Revision 1.1
-- Last edited: 3/4/18
------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity byteBuffer is
	Port ( D : in STD_LOGIC_VECTOR (7 downto 0);
	       rst : in STD_LOGIC;
	       latch : in STD_LOGIC;
	       Q : out STD_LOGIC_VECTOR (7 downto 0) := (others => '0'));
end byteBuffer;

architecture Behavioral of byteBuffer is

	component DFF
		port ( D : in STD_LOGIC;
		       clk : in STD_LOGIC;
		       rst: in STD_LOGIC;
		       Q : out STD_LOGIC);
	end component;

begin

	-- Generate 8 bits of the register
	REGISTER_GEN : for I in 0 to 7 generate 

		-- Route input to output
		DFF_INST : DFF port map (D => D(I), 
					 clk => latch, 
					 rst => rst, 
					 Q => Q(I));

	end generate REGISTER_GEN;

end Behavioral;
