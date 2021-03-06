------------------------------------------------------------------------------
-- File:
--	integrated.vhd
--
-- Description:
--	This is the integration between the three serial LVDS interfaces to the
--	sensor (D1, D2, CONTROL). The primary inputs are the three serial input
--	lines and the outputs are the 2 x 32-bit buses sent out to a FIFO
--	connected to the xillybus rh and rl channels, as well as a latch to
--	properly write the data to the FIFO
--
-- Author:
--	David Stockhouse
--
-- Revision 1.2
-- Last edited: 7/26/18
------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity integrated is
	Port ( lvds_d1 : in STD_LOGIC;
	       lvds_d2 : in STD_LOGIC;
	       lvds_ctl : in STD_LOGIC;
	       lvds_clk : in STD_LOGIC;
	       pix_clk : in STD_LOGIC;
	       rst : in STD_LOGIC;
	       out_high : out STD_LOGIC_VECTOR(31 downto 0);
	       out_low : out STD_LOGIC_VECTOR(31 downto 0);
	       latch : out STD_LOGIC;
	       eof : out STD_LOGIC);
end integrated;

architecture Behavioral of integrated is


	------ External component declarations ------

	component interface
		Port ( d : in STD_LOGIC;
		       train_en : in STD_LOGIC;
		       train : in STD_LOGIC_VECTOR (9 downto 0);
		       pix_clk : in STD_LOGIC;
		       clk : in STD_LOGIC;
		       rst : in STD_LOGIC;
		       out_latch : out STD_LOGIC := '0';
		       locked : out STD_LOGIC := '0';
		       q : out STD_LOGIC_VECTOR (7 downto 0) := (others => '0'));
	end component;


	------ Internal signal declarations ------

	signal int_train, int_latch1, int_latch2, int_latch_ctl, int_latch_master : std_logic;
	signal int_locked1, int_locked2, int_locked_ctl : std_logic;
	signal q1, q2, q_ctl : std_logic_vector (7 downto 0);

	-- Signals that are certain bits in the control channel
	signal dval, fval, lval : std_logic;
	signal frame_started : std_logic;

	-- 4 byte data shift registers
	type shift is array (0 to 3) of std_logic_vector(7 downto 0);
	signal int_d1, int_d2 : shift;
	
	-- Counts 4 bytes to send to FIFO
	signal counter_d1, counter_d2, counter_ctl : integer := 0;

begin

	INTERFACE_1 : interface port map (d => lvds_d1,
					  rst => rst,
					  clk => lvds_clk,
					  pix_clk => pix_clk,
					  train_en => int_train,
					  train => "0001010101",
					  out_latch => int_latch1,
					  locked => int_locked1,
					  q => q1);

	INTERFACE_2 : interface port map (d => lvds_d2,
					  rst => rst,
					  clk => lvds_clk,
					  pix_clk => pix_clk,
					  train_en => int_train,
					  train => "0001010101",
					  out_latch => int_latch2,
					  locked => int_locked2,
					  q => q2);

	INTERFACE_ctl : interface port map (d => lvds_ctl,
					    rst => rst,
					    clk => lvds_clk,
					    pix_clk => pix_clk,
					    train_en => int_train,
					    train => "1000000000",
					    out_latch => int_latch_ctl,
					    locked => int_locked_ctl,
					    q => q_ctl);


	-- Parse the bits of the control channel 
	dval <= '0' when rst = '1' else
		q_ctl(0);
	fval <= '0' when rst = '1' else
		q_ctl(2);
	lval <= '0' when rst = '1' else
		q_ctl(1);


	-- Monitor fval signal of the CTL line for valid frame information
	FRAMING : process(fval, rst)
	begin

		if rst = '0' then
			-- Keep track of whether we are in a valid frame readout
			if rising_edge(fval) then

			-- Indicate frame readout has become valid
				frame_started <= '1';

			end if; -- rising_edge(fval)

			if(falling_edge(fval)) then

			-- Send EOF to xillybus ports
				eof <= '1';

			end if; -- falling_edge(fval)

		else

			frame_started <= '0';
			eof <= '0';

		end if; -- rst

	end process; -- FRAMING


	-- Shift the data if any of the LVDS channels latch
	LATCH_SHIFT : process(int_latch1, int_latch2, int_latch_ctl)

		variable latch_counter : integer := 0;

	begin

		if rst = '0' then

			-- Only shift data if data is valid
			if dval = '1' then

				-- If rising edge on any latch, shift those latched bytes

				if rising_edge(int_latch1) then
					for I in 3 downto 1 loop
						int_d1(I) <= int_d1(I-1);
						int_d1(0) <= q1;
					end loop;
				end if;

				if rising_edge(int_latch2) then
					for I in 3 downto 1 loop
						int_d2(I) <= int_d2(I-1);
						int_d2(0) <= q2;
					end loop;
				end if;

				-- Increment counter
				latch_counter := latch_counter + 1;

				if latch_counter > 3 then

					-- Reset counter
					latch_counter := 0;

					-- Send internal signals to output. First concatenate 32 bits together
					out_high <= (others => '0') when rst = '1' else
						    int_d2(3) & int_d2(2) & int_d2(1) & int_d2(0);
					out_low <= (others => '0') when rst = '1' else
						   int_d1(3) & int_d1(2) & int_d1(1) & int_d1(0);
			else

				latch_counter := 0;

			end if; -- dval = '1', so CTL says there is valid pixel data on the input channels

		else

			int_d1 <= (others => (others => '0'));
			int_d2 <= (others => (others => '0'));
			latch_counter := 0;

			out_high <= (others => '0');
			out_low <= (others => '0');

		end if; -- rst

	end process; -- LATCH_SHIFT

end Behavioral;
