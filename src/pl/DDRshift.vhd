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
-- Revision 1.1
-- Last edited: 3/4/18
------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity DDRshift is
	Port ( D : in STD_LOGIC;
	       clk : in STD_LOGIC;
	       rst : in STD_LOGIC;
	       Q : out STD_LOGIC_VECTOR (9 downto 0) := (others => '0'));
end DDRshift;

architecture Behavioral of DDRshift is

	component DDRblock
		Port ( D : in STD_LOGIC;
		       clk : in STD_LOGIC;
		       rst : in STD_LOGIC;
		       D_rising : out STD_LOGIC;
		       D_falling : out STD_LOGIC;
		       clkout : out STD_LOGIC);
	end component;

	component DFF
		Port ( D : in STD_LOGIC;
		       clk : in STD_LOGIC;
		       rst : in STD_LOGIC;
		       Q : out STD_LOGIC);
	end component;

	-- Internal signals from the DDR block on the rising and falling edges
	signal int_rise, int_fall, int_clk : std_logic := '0';

	-- Internal signals between D flip flops to shift the shift register
	signal internal : std_logic_vector(9 downto 0) := (others => '0');

begin

	-- Setup the DDR block
	DDRBLOCK_GEN : DDRblock port map(D => D,
					 clk => clk,
					 rst => rst,
					 D_rising => int_rise,
					 D_falling => int_fall,
					 clkout => int_clk);

	internal(9) <= int_fall when rising_edge(int_clk);
	internal(8) <= int_rise when rising_edge(int_clk);

	-- Create 5 steps for the DDR shift register
	SHIFT_GEN : for I in 0 to 3 generate

		internal((2*I) + 1) <= internal((2*(I + 1)) + 1) when rising_edge(int_clk);
		internal(2*I) <= internal(2*(I + 1)) when rising_edge(int_clk);

--
--		-- Setup the edge case to route the first input from DDR block
--		INIT : if I = 4 generate
--
--			START_FALL : DFF port map(D => int_fall,
--						  clk => int_clk,
--						  rst => rst,
--						  Q => internal(9));
--
--			START_RISE : DFF port map(D => int_rise,
--						  clk => int_clk,
--						  rst => rst,
--						  Q => internal(8));
--		end generate INIT;
--
--		OTHER_BITS : if I < 4 generate
--
--			DFF_FALL : DFF port map(D => internal((2*(I + 1)) + 1),
--						clk => int_clk,
--						rst => rst,
--						Q => internal((2*I) + 1));
--
--			DFF_RISE : DFF port map(D => internal(2*(I + 1)),
--						clk => int_clk,
--						rst => rst,
--						Q => internal(2*I));
--		end generate OTHER_BITS;

	end generate SHIFT_GEN;


	-- Move internal signals to output
	Q <= internal;

end Behavioral;
