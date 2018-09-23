------------------------------------------------------------------------------
-- File:
--	DDRshift.vhd
--
-- Description:
--	A dual data rate (DDR) shift register, the bit length is an even generic
--	quantity.
--
-- Author:
--	David Stockhouse & Sam Janoff
--
-- Revision 1.4
-- Last edited: 7/28/18
------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity DDRshift is
	Generic ( bits : integer := 10);
	Port ( d : in STD_LOGIC;
	       clk : in STD_LOGIC;
	       rst : in STD_LOGIC;
	       q : out STD_LOGIC_VECTOR ((bits-1) downto 0));
end DDRshift;

architecture Behavioral of DDRshift is

	component DDRblock
		Port ( d : in STD_LOGIC;
		       clk : in STD_LOGIC;
		       rst : in STD_LOGIC;
		       q_rising : out STD_LOGIC;
		       q_falling : out STD_LOGIC;
		       clkout : out STD_LOGIC);
	end component;

	-- Internal signals from the DDR block on the rising and falling edges
	signal int_rise, int_fall, int_clk : std_logic := '0';

	-- Internal signals between D flip flops to shift the shift register
	signal internal : std_logic_vector((bits-1) downto 0) := (others => '1');

begin

	-- Setup the DDR block
	DDRBLOCK_INS : DDRblock port map(d => d,
					 clk => clk,
					 rst => rst,
					 q_rising => int_rise,
					 q_falling => int_fall,
					 clkout => int_clk);

<<<<<<< HEAD
	internal(8) <= '0' when rst = '1' else
		       int_fall when rising_edge(int_clk);
	internal(9) <= '0' when rst = '1' else
		       int_rise when rising_edge(int_clk);
=======
	-- Process to shift serial input data 2 lines at a time to satisfy the
	-- DDR signals
	SHIFT : process(clk, rst)
	begin
>>>>>>> new_ddr

		-- Asynchronous reset
		if rst = '1' then
			-- Reset internal signal
			internal <= (others => '0');

		-- Rising edge on the internal clock
		elsif clk'EVENT and clk = '0' then

			-- MSBs
			internal(bits-1) <= int_fall;
			internal(bits-2) <= int_rise;

			-- Loop through the rest of the word
			for I in 0 to ((bits/2) - 2) loop

				internal((2*I) + 1) <= internal((2*(I + 1)) + 1);
				internal(2*I) <= internal(2*(I + 1));

			end loop;

		end if; -- rst/clk

	end process; -- SHIFT

	-- Move internal signals directly to output
	q <= internal;

end Behavioral;
