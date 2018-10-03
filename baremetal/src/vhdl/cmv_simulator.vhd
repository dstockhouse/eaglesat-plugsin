------------------------------------------------------------------------------
-- File:
--	cmv_simulator.vhd
--
-- Description:
--	This block simulates the output of the CMV2000 to test the operation of
--	the interface.
--
-- Author:
--	David Stockhouse
--
-- Revision 1.1
-- Last edited: 9/30/18
------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use IEEE.NUMERIC_STD.ALL;


entity cmv_simulator is
	Port ( 
			 frame_req : in STD_LOGIC;
		     clk : in STD_LOGIC;
			 pix_clk : in STD_LOGIC;
		     rst : in STD_LOGIC;
		     d1 : out STD_LOGIC;
		     d2 : out STD_LOGIC;
		     d_ctl : out STD_LOGIC;
		     lvds_clk : out STD_LOGIC
	     );
end cmv_simulator;

architecture Behavioral of cmv_simulator is

	constant PIXELS_PER_ROW : natural := 2048;
	constant NUM_ROWS : natural := 1088;

	constant TRAIN_SIGNAL : std_logic_vector(9 downto 0) := "0001010101";
	constant CTL_SIGNAL_TRAIN : std_logic_vector(9 downto 0) := "1000000000";
	constant CTL_SIGNAL_FVAL : std_logic_vector(9 downto 0) := "1000000110";
	constant CTL_SIGNAL_DVAL : std_logic_vector(9 downto 0) := "1000000111";

	signal int_d1, int_d2, int_ctl, int_train, int_lvds_clk, inv_lvds_clk : std_logic;

	signal output_word_1 : std_logic_vector (9 downto 0) := TRAIN_SIGNAL;
	signal output_word_2 : std_logic_vector (9 downto 0) := TRAIN_SIGNAL;
	signal ctl_word : std_logic_vector (9 downto 0) := CTL_SIGNAL_TRAIN;

	signal cmv_packet_counter : integer := 0;
	signal cmv_frame_counter : integer := (NUM_ROWS * PIXELS_PER_ROW) - 1;
	signal cmv_overhead_counter : integer := 15;
	signal initial_delay : integer := 15;

	type STATE_TYPE is (valid, train, initial, overhead);
	signal state : STATE_TYPE;

begin

	inv_lvds_clk <= not int_lvds_clk;
	lvds_clk <= int_lvds_clk;
	d1 <= int_d1;
	d2 <= int_d2;
	d_ctl <= int_ctl;

	CLOCK_DIVIDER : process(clk, rst)
		variable lvds_clk_counter : std_logic_vector (1 downto 0);
	begin

		-- Active low reset
		if rst = '0' then

			lvds_clk_counter := (others => '0');
			int_lvds_clk <= '0';

		else
			if clk'event and clk = '1' then

				-- Get divided clock
				int_lvds_clk <= lvds_clk_counter(1);
				
--				lvds_clk_counter := to_stdlogicvector(unsigned(lvds_clk_counter, lvsd_clk_counter'length) + 1);
				lvds_clk_counter := lvds_clk_counter + 1;

			end if;
		end if;

	end process; -- CLOCK_DIVIDER

	PIXEL_SETUP : process(pix_clk, rst)

		variable training : std_logic := '1';
		
		variable vector_counter : std_logic_vector (31 downto 0);

		variable dval, fval, lval : std_logic := '0';

	begin

		-- Active low reset
		if rst = '0' then

			state <= Train;

			cmv_packet_counter <= 0;
			-- cmv_frame_counter <= (NUM_ROWS * PIXELS_PER_ROW) - 1;
			cmv_frame_counter <= 0;
			cmv_overhead_counter <= 0;
			initial_delay <= 0;

			dval := '0';
			lval := '0';
			fval := '0';

			training := '1';

		else

			if pix_clk'event and pix_clk = '1' then

				case state is
					when train =>

						dval := '0';
						lval := '0';
						fval := '0';

						-- frame_req is the trigger
						if frame_req = '1' then
							state <= initial;
							cmv_frame_counter <= (NUM_ROWS * PIXELS_PER_ROW) - 1;
							initial_delay <= 16;
							training := '1';
						end if;


					when initial => 

						dval := '0';
						lval := '0';
						fval := '0';

						-- Initial delay as soon as readout begins
						if initial_delay > 0 then
							initial_delay <= initial_delay - 1;
						else
							-- After delay start first packet
							state <= valid;
							training := '0';
							cmv_packet_counter <= 127;
						end if;
		

					when overhead =>

						dval := '0';
						lval := '1';
						fval := '1';

						-- Counter for overhead period between packets
						if cmv_overhead_counter > 0 then
							cmv_overhead_counter <= cmv_overhead_counter - 1;
						else
							-- After overhead start next packet
							state <= valid;
							training := '0';
							cmv_packet_counter <= 127;
						end if;
		
					when valid =>

						dval := '1';
						lval := '1';
						fval := '1';

						-- Counter for total pixels in a frame
						if cmv_frame_counter > 0 then
							cmv_frame_counter <= cmv_frame_counter - 1;
						else
							state <= train;
							training := '1';
						end if;

						-- Counter for pixels output at each packet
						if cmv_packet_counter > 0 then
							cmv_packet_counter <= cmv_packet_counter - 1;
						else
							-- If more data to write, start the next overhead period
							if cmv_frame_counter > 0 then
								state <= overhead;
								training := '1';
								cmv_overhead_counter <= 15;
							end if;
						end if;

				end case; -- state

				-- Assign data to be output based on values determined earlier
				ctl_word <= "1000000" & fval & lval & dval;

				if training = '1' then
					output_word_1 <= TRAIN_SIGNAL;
					output_word_2 <= TRAIN_SIGNAL;
				else
					vector_counter := std_logic_vector(to_unsigned(cmv_frame_counter, 32));
					output_word_1 <= vector_counter(11 downto 2);
                    output_word_2 <= vector_counter(9 downto 0);
				end if;

			end if; -- Rising edge pix_clk

		end if; -- rst

	end process; -- PIXEL_SETUP



	SIG_GEN : process(int_lvds_clk, inv_lvds_clk, rst)

			variable current_bit : integer := 9;

	begin
		if rst = '0' then

			int_d1 <= '0';
			int_d2 <= '0';
			int_ctl <= '0';
			int_train <= '0';

		else
			-- Rising or falling edge of the clock
			if (int_lvds_clk'event and int_lvds_clk = '1') or (inv_lvds_clk'event and inv_lvds_clk = '1') then

				-- Output one bit of the output word
				int_d1 <= output_word_1(current_bit);
				int_d2 <= output_word_2(current_bit);
				int_ctl <= ctl_word(current_bit);

				if current_bit > 0 then
					current_bit := current_bit - 1;
				else
					current_bit := 9;
				end if;

			end if; -- Rising or Falling edge of lvds_clk

		end if; -- rst

	end process; -- SIG_GEN

end Behavioral;

