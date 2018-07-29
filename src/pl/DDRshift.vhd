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
-- Revision 1.3
-- Last edited: 7/28/18
------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity DDRshift is
	Generic ( bits : integer := 10);
	Port ( d : in STD_LOGIC;
	       clk : in STD_LOGIC;
	       rst : in STD_LOGIC;
	       q : out STD_LOGIC_VECTOR ((bits-1) downto 0) := (others => '0'));
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
	signal internal : std_logic_vector((bits-1) downto 0) := (others => '0');

begin

	-- Setup the DDR block
	DDRBLOCK_INS : DDRblock port map(d => d,
					 clk => clk,
					 rst => rst,
					 d_rising => int_rise,
					 d_falling => int_fall,
					 clkout => int_clk);

	-- Process to shift serial input data 2 lines at a time to satisfy the
	-- DDR signals
	SHIFT : process(int_clk, rst)
	begin

		-- Asynchronous reset
		if rst = '1' then
			-- Reset internal signal
			internal <= (others => '0');

		-- Rising edge on the internal clock
		elsif int_clk'EVENT and int_clk = '1' then

			-- MSBs
			internal(bits-1) <= int_fall;
			internal(bits-2) <= int_rise;

			-- Loop through the rest of the word
			for I in 0 to ((bits/2) - 2) loop

				internal((2*I) + 1) <= internal((2*(I + 1)) + 1);
				internal(2*I) <= internal(2*(I + 1));

			end loop;

		end if;

	end process; -- SHIFT

	-- Move internal signals directly to output
	q <= internal;

end Behavioral;
