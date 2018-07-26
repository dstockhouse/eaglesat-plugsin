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
-- Revision 1.3
-- Last edited: 7/26/18
------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity DDRlatch is
	Port ( d : in STD_LOGIC;
	       clk : in STD_LOGIC;
	       rst : in STD_LOGIC;
	       latch : out STD_LOGIC;
	       q : out STD_LOGIC_VECTOR (9 downto 0) := (others => '0'));
end DDRlatch;

architecture Behavioral of DDRlatch is

	component DDRshift is
		Port ( d : in STD_LOGIC;
		       clk : in STD_LOGIC;
		       rst : in STD_LOGIC;
		       q : out STD_LOGIC_VECTOR (9 downto 0));
	end component;

	-- Internal signal between the output of the SR and input of buffer
	signal internal : STD_LOGIC_VECTOR (9 downto 0) := (others => '0');

	-- Internal buffer latch and inverted clock
	signal int_latch, inv_clk : STD_LOGIC := '0';

begin

	-- Inverted clock signal
	inv_clk <= not clk;

	-- Generate DDR shift register
	SHIFT_GEN : DDRshift port map (d => d,
	                               clk => clk,
	                               rst => rst, 
	                               q => internal);

	process (clk, inv_clk, rst)
		variable count : integer := 0;
	begin

		-- Asynchronous reset of everything
		if rst = '1' then
			q <= (others => '0');
			latch <= '0';
			int_latch <= '0';
			count := 0;

		-- Check for rising or falling edge of input clock
		elsif (clk'EVENT and clk = '1') or (inv_clk'EVENT and inv_clk = '1') then

			-- Increment counter
			count := count + 1;

			-- The automatic latching works as follows:
			------  Once ten bits have been shifted in, the input is
			-- 	routed to the output and the internal latch is 
			-- 	set
			------  One clock edge later, the external latch is set
			------  One clock edge later, the external latch is reset
			-- This allows time for the input signal to propagate to
			-- the output before the external latch is set, to
			-- ensure that any later circuitry can correctly clock
			-- in the proper buffered data, and that the external
			-- latch is never set for more than half of a clock
			-- pulse

			-- Check if internal latch has been set
			if int_latch = '1' then
				-- Set external latch
				latch <= '1';
				-- Reset internal latch
				int_latch <= '0';
			else
				-- Reset external latch
				latch <= '0';
			end if; -- Internal latch

			-- Check if count exceeded
			if count >= 10 then
				-- Latch data to output buffer
				q <= internal;
				-- Set internal latch
				int_latch <= '1';
				-- Reset counter
				count := 0;
			end if; -- Counter

		end if; -- rst else clock edge

	end process;

end Behavioral;
