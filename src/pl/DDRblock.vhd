------------------------------------------------------------------------------
-- File:
--	DDRblock.vhd
--
-- Description:
--	A block that splits up an input DDR serial stream into two rising edge
--	serial streams to be fed into a shift register. This block was designed
--	using an application note from Texas Instruments "Understanding Serial
--	LVDS Capture in High-Speed ADCs"
--
-- Author:
--	David Stockhouse & Sam Janoff
--
-- Revision 1.2
-- Last edited: 6/10/18
------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity DDRblock is
	Port ( D : in STD_LOGIC;
	       clk : in STD_LOGIC;
	       rst : in STD_LOGIC;
	       D_rising : out STD_LOGIC;
	       D_falling : out STD_LOGIC;
	       clkout : out STD_LOGIC);
end DDRblock;

architecture Behavioral of DDRblock is

	-- Inverted clock signal and internal signal between the falling edge
	-- DFF and the relatching DFF
	signal inv_clk, D_out_falling : std_logic := '0';

begin

	-- Inverse clock
	inv_clk <= not clk;

	-- Output clock is the same as the input clock
	clkout <= clk;

	D_rising <= D when rising_edge(clk);
	D_falling <= D_out_falling when rising_edge(clk);
	D_out_falling <= D when rising_edge(inv_clk);

end Behavioral;
