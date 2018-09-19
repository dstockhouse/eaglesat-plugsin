------------------------------------------------------------------------------
-- File:
--	match.vhd
--
-- Description:
--	Takes in a 10-bit word and a key to match it against to see if they
--	match. Outputs one bit indicating whether they match or not and an
--	integer amount that the input word needs to be shifted by to make
--	the match occur.
--
-- Author:
--	David Stockhouse
--
-- Revision 1.0
-- Last edited: 3/31/18
------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.NUMERIC_STD.ALL;

entity match is
	Port ( test : in STD_LOGIC_VECTOR (9 downto 0);
	       key : in STD_LOGIC_VECTOR (9 downto 0);
	       train_en : in STD_LOGIC;
	       rst : in STD_LOGIC;
	       matched : out STD_LOGIC;
	       shifted : out STD_LOGIC_VECTOR (9 downto 0);
	       shift : out INTEGER);
end match;

architecture Behavioral of match is

	-- int_shifted stores the input 10-bit test value rotated each 10 bits
	type shift_t is array (0 to 9) of std_logic_vector(9 downto 0);
	signal int_shifted : shift_t;

	-- Boolean indicating which shifted strings match the key
	signal int_match : std_logic_vector(9 downto 0);

	signal int_shift : integer := 0;

	signal int_count : integer := 0;

begin

	ROTATE_GEN : for I in 0 to 9 generate

		int_shifted(I) <= (others => '0') when rst = '1' else
				  to_stdlogicvector(to_bitvector(test) rol I);

	end generate ROTATE_GEN;

	MATCH_GEN : for I in 0 to 9 generate

		int_match(I) <= '1' when int_shifted(I) = key and train_en = '1' and rst = '0' else
				'0';

	end generate MATCH_GEN;

	-- Count up all the bits in int_match
	int_count <= conv_integer(int_match(0)) + 
		     conv_integer(int_match(1)) +
		     conv_integer(int_match(2)) +
		     conv_integer(int_match(3)) +
		     conv_integer(int_match(4)) +
		     conv_integer(int_match(5)) +
		     conv_integer(int_match(6)) +
		     conv_integer(int_match(7)) +
		     conv_integer(int_match(8)) +
		     conv_integer(int_match(9)) when train_en = '1' and rst = '0' else
		     0 when not rst = '0';

	SHIFTING : process (int_match, rst)
	begin

		SHIFT_GEN : for I in 0 to 9 loop

			if int_match(I) = '1' and train_en = '1' and rst = '0' then
				int_shift <= I;
			elsif not rst = '0' then
				int_shift <= 0;
			end if;

		end loop; -- SHIFT_GEN

	end process; -- SHIFTING

	matched <= '1' when int_count > 0 and rst = '0' else
		   '0';

	shifted <= (others => '0') when rst = '1' else
		   int_shifted(int_shift);
	
	shift <= 0 when rst = '1' else
		 int_shift;

end Behavioral;
