------------------------------------------------------------------------------
-- File:
--	byte_shift.vhd
--
-- Description:
--	32-bit byte-wise shift register. The 32-bit output channel can be fed 
--	into a FIFO from a higher module. Input clock pulses must be counted 
--	and the output must be latched from a higher module.
--
-- Author:
--	David Stockhouse
--
-- Revision 1.1
-- Last edited: 7/03/18
------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.NUMERIC_STD.ALL;


entity byte_shift is
	Port ( d : in STD_LOGIC_VECTOR (7 downto 0);
	       clk : in STD_LOGIC;
	       rst : in STD_LOGIC;
	       q : out STD_LOGIC_VECTOR (31 downto 0));
end byte_shift;


architecture Behavioral of byte_shift is

	-- The internal signal will actively shift in bytes from the input 
	-- channel and it is latched to the output at 4-byte intervals
	type vector_array is array (3 downto 0) of std_logic_vector (7 downto 0);
	signal internal : vector_array := (others => (others => '0'));

begin

	INTERNAL_SHIFT : for I in 0 to 2 generate
		internal(I) <= (others => '0') when rst = '1' else
			       internal(I+1) when rising_edge(clk);
	end generate; -- INTERNAL_SHIFT

	-- First byte fed directly from input
	internal(3) <= (others => '0') when rst = '1' else
		       d when rising_edge(clk);

	q <= (others => '0') when rst = '1' else
	     internal(3) & internal(2) & internal(1) & internal(0);

end Behavioral;
