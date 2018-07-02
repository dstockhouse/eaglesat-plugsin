------------------------------------------------------------------------------
-- File:
--	byte_shift.vhd
--
-- Description:
--	32-bit byte-wise shift register. The 32-bit output channel can be fed 
--	into a FIFO from a higher module.
--
-- Author:
--	David Stockhouse
--
-- Revision 1.0
-- Last edited: 7/2/18
------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.NUMERIC_STD.ALL;


entity byte_shift is
	Port ( d : in STD_LOGIC_VECTOR (7 downto 0);
	       latch : in STD_LOGIC;
	       rst : in STD_LOGIC;
	       q : out STD_LOGIC_VECTOR (31 downto 0);
	       out_latch : out STD_LOGIC);
end byte_shift;


architecture Behavioral of byte_shift is

	-- The internal signal will actively shift in bytes from the input 
	-- channel and it is latched to the output at 4-byte intervals
	type vector_array is array (3 downto 0) of std_logic_vector (7 downto 0);
	signal internal : vector_array := (others => (others => '0'));

	-- Internal buffer for out_latch that can be read from
	signal internal_out_latch : std_logic;

	-- Byte counter
	signal count : integer := 0;

begin

	INTERNAL_SHIFT : for I in 0 to 2 generate
		internal(I) <= (others => '0') when rst = '1' else
			       internal(I+1) when rising_edge(latch);
	end generate; -- INTERNAL_SHIFT
	-- First byte fed directly from input
	internal(3) <= (others => '0') when rst = '1' else
		       d when rising_edge(latch);

	-- Count bytes received to latch the output after every 4 bytes
	BYTE_COUNT : process(latch, rst)
	begin

		-- First check reset signal
		if not rst = '1' then

			-- Reset output latch if it is set
			if internal_out_latch = '1' then
				internal_out_latch <= '0';
			end if;

			-- Increment counter for every latch observed
			if rising_edge(latch) then
				count <= count + 1;
			end if;

		else
			-- Reset signals to 0
			count <= 0;

		end if; -- rst

	end process; -- BYTE_COUNT

	-- Rollover counter and latch output
	LATCH_OUT : process(count, rst)
	begin

		-- First check rst signal
		if not rst = '1' then

			-- If count exceeds 3, rollover to 0 and latch the output
			if count > 3 then
				count <= 0;
				q <= internal(3) & internal(2) & internal(1) & internal(0);
				internal_out_latch <= '1';
			end if;

		else
			-- Reset signals to 0
			q <= (others => '0');
			internal_out_latch <= '0';

		end if; -- rst

	end process; -- LATCH_OUT

	-- out_latch always the same as internal_out_latch
	out_latch <= '0' when rst = '1' else
		     internal_out_latch;

end Behavioral;
