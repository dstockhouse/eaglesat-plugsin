------------------------------------------------------------------------------
-- File:
--	DDRshift.vhd
--
-- Description:
--	A dual data rate (DDR) 10-bit shift register
--
-- Author:
--	David Stockhouse & Sam Janoff
--
-- Revision 1.2
-- Last edited: 7/03/18
------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity DDRshift is
	Port ( d : in STD_LOGIC;
	       clk : in STD_LOGIC;
	       rst : in STD_LOGIC;
	       q : out STD_LOGIC_VECTOR (9 downto 0) := (others => '0'));
end DDRshift;

architecture Behavioral of DDRshift is

	component DDRblock
		Port ( d : in STD_LOGIC;
		       clk : in STD_LOGIC;
		       rst : in STD_LOGIC;
		       d_rising : out STD_LOGIC;
		       d_falling : out STD_LOGIC;
		       clkout : out STD_LOGIC);
	end component;

	-- Internal signals from the DDR block on the rising and falling edges
	signal int_rise, int_fall, int_clk : std_logic := '0';

	-- Internal signals between D flip flops to shift the shift register
	signal internal : std_logic_vector(9 downto 0) := (others => '0');

begin

	-- Setup the DDR block
	DDRBLOCK_GEN : DDRblock port map(d => d,
					 clk => clk,
					 rst => rst,
					 d_rising => int_rise,
					 d_falling => int_fall,
					 clkout => int_clk);

	internal(9) <= '0' when rst = '1' else
		       int_fall when rising_edge(int_clk);
	internal(8) <= '0' when rst = '1' else
		       int_rise when rising_edge(int_clk);

	-- Create 5 steps for the DDR shift register
	SHIFT_GEN : for I in 0 to 3 generate

		internal((2*I) + 1) <= '0' when rst = '1' else
			               internal((2*(I + 1)) + 1) when rising_edge(int_clk);
		internal(2*I) <= '0' when rst = '1' else
				 internal(2*(I + 1)) when rising_edge(int_clk);

	end generate SHIFT_GEN;

	-- Move internal signals to output
	q <= (others => '0') when rst = '1' else
	     internal;

end Behavioral;
