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
-- Revision 1.4
-- Last edited: 8/13/18
------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity DDRblock is
	Port ( d : in STD_LOGIC;
	       clk : in STD_LOGIC;
	       rst : in STD_LOGIC;
	       q_rising : out STD_LOGIC;
	       q_falling : out STD_LOGIC;
	       clkout : out STD_LOGIC);
end DDRblock;

architecture Behavioral of DDRblock is

	-- Inverted clock signal and internal signal between the falling edge
	-- DFF and the relatching DFF
	signal inv_clk : std_logic;
	signal buf_rising, buf_falling, buf_falling_relatched : std_logic := '0';

begin

	-- Inverse clock
	inv_clk <= '0' when rst = '1' else
		   not clk;

	-- Output clock is the same as the input clock
	clkout <= '0' when rst = '1' else
		  clk;

	LATCH : process(clk, inv_clk, rst)
	begin

		if rst = '1' then

			q_rising <= '0';
			q_falling <= '0';

		else
			-- Rising edge 
			if clk'EVENT and clk = '1' then

				buf_rising <= d;

			end if; -- rising edge

			-- Falling edge
			if clk'EVENT and clk = '0' then

				q_falling <= d;
				q_rising <= buf_rising;

			end if; -- falling edge

		end if; -- rst

	end process; -- LATCH

end Behavioral;
