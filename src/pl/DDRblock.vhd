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
-- Last edited: 7/03/18
------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity DDRblock is
	Port ( d : in STD_LOGIC;
	       clk : in STD_LOGIC;
	       rst : in STD_LOGIC;
	       d_rising : out STD_LOGIC;
	       d_falling : out STD_LOGIC;
	       clkout : out STD_LOGIC);
end DDRblock;

architecture Behavioral of DDRblock is

	-- Inverted clock signal and internal signal between the falling edge
	-- DFF and the relatching DFF
	signal inv_clk, d_out_falling : std_logic := '0';

begin

	-- Inverse clock
	inv_clk <= '0' when rst = '1' else
		   not clk;

	-- Output clock is the same as the input clock
	clkout <= '0' when rst = '1' else
		  clk;

	d_rising <= '0' when rst = '1' else
		    d when rising_edge(clk);
	d_falling <= '0' when rst = '1' else
		     d_out_falling when rising_edge(clk);
	d_out_falling <= '0' when rst = '1' else
			 d when rising_edge(inv_clk);

end Behavioral;
