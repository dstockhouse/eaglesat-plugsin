------------------------------------------------------------------------------
-- File:
--	xillydemo.vhd
--
-- Description:
--	This is a modification of the xillydemo example code, using the same
--	xillybus interface. This is to test the functionality of the interface
--	to the sensor before we have custom xillybus up and running.
--
-- Author:
--	David Stockhouse
--
-- Revision 1.0
-- Last edited: 8/29/18
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity xillydemo is
  port (
    -- For Vivado, delete the port declarations for PS_CLK, PS_PORB and
    -- PS_SRSTB, and uncomment their declarations as signals further below.

    PS_CLK : IN std_logic;
    PS_PORB : IN std_logic;
    PS_SRSTB : IN std_logic;
    clk_100 : IN std_logic;
    otg_oc : IN std_logic;
    PS_GPIO : INOUT std_logic_vector(55 DOWNTO 0);
    GPIO_LED : OUT std_logic_vector(3 DOWNTO 0);
    vga4_blue : OUT std_logic_vector(3 DOWNTO 0);
    vga4_green : OUT std_logic_vector(3 DOWNTO 0);
    vga4_red : OUT std_logic_vector(3 DOWNTO 0);
    vga_hsync : OUT std_logic;
    vga_vsync : OUT std_logic;
    audio_mclk : OUT std_logic;
    audio_dac : OUT std_logic;
    audio_adc : IN std_logic;
    audio_bclk : IN std_logic;
    audio_lrclk : IN std_logic;
    smb_sclk : OUT std_logic;
    smb_sdata : INOUT std_logic;
    smbus_addr : OUT std_logic_vector(1 DOWNTO 0));
  end xillydemo;

architecture sample_arch of xillydemo is
  component xillybus
    port (
      PS_CLK : IN std_logic;
      PS_PORB : IN std_logic;
      PS_SRSTB : IN std_logic;
      clk_100 : IN std_logic;
      otg_oc : IN std_logic;
      DDR_Addr : INOUT std_logic_vector(14 DOWNTO 0);
      DDR_BankAddr : INOUT std_logic_vector(2 DOWNTO 0);
      DDR_CAS_n : INOUT std_logic;
      DDR_CKE : INOUT std_logic;
      DDR_CS_n : INOUT std_logic;
      DDR_Clk : INOUT std_logic;
      DDR_Clk_n : INOUT std_logic;
      DDR_DM : INOUT std_logic_vector(3 DOWNTO 0);
      DDR_DQ : INOUT std_logic_vector(31 DOWNTO 0);
      DDR_DQS : INOUT std_logic_vector(3 DOWNTO 0);
      DDR_DQS_n : INOUT std_logic_vector(3 DOWNTO 0);
      DDR_DRSTB : INOUT std_logic;
      DDR_ODT : INOUT std_logic;
      DDR_RAS_n : INOUT std_logic;
      DDR_VRN : INOUT std_logic;
      DDR_VRP : INOUT std_logic;
      MIO : INOUT std_logic_vector(53 DOWNTO 0);
      PS_GPIO : INOUT std_logic_vector(55 DOWNTO 0);
      DDR_WEB : OUT std_logic;
      GPIO_LED : OUT std_logic_vector(3 DOWNTO 0);
      bus_clk : OUT std_logic;
      quiesce : OUT std_logic;
      vga4_blue : OUT std_logic_vector(3 DOWNTO 0);
      vga4_green : OUT std_logic_vector(3 DOWNTO 0);
      vga4_red : OUT std_logic_vector(3 DOWNTO 0);
      vga_hsync : OUT std_logic;
      vga_vsync : OUT std_logic;
      user_r_mem_8_rden : OUT std_logic;
      user_r_mem_8_empty : IN std_logic;
      user_r_mem_8_data : IN std_logic_vector(7 DOWNTO 0);
      user_r_mem_8_eof : IN std_logic;
      user_r_mem_8_open : OUT std_logic;
      user_w_mem_8_wren : OUT std_logic;
      user_w_mem_8_full : IN std_logic;
      user_w_mem_8_data : OUT std_logic_vector(7 DOWNTO 0);
      user_w_mem_8_open : OUT std_logic;
      user_mem_8_addr : OUT std_logic_vector(4 DOWNTO 0);
      user_mem_8_addr_update : OUT std_logic;
      user_r_read_32_rden : OUT std_logic;
      user_r_read_32_empty : IN std_logic;
      user_r_read_32_data : IN std_logic_vector(31 DOWNTO 0);
      user_r_read_32_eof : IN std_logic;
      user_r_read_32_open : OUT std_logic;
      user_r_read_8_rden : OUT std_logic;
      user_r_read_8_empty : IN std_logic;
      user_r_read_8_data : IN std_logic_vector(7 DOWNTO 0);
      user_r_read_8_eof : IN std_logic;
      user_r_read_8_open : OUT std_logic;
      user_w_write_32_wren : OUT std_logic;
      user_w_write_32_full : IN std_logic;
      user_w_write_32_data : OUT std_logic_vector(31 DOWNTO 0);
      user_w_write_32_open : OUT std_logic;
      user_w_write_8_wren : OUT std_logic;
      user_w_write_8_full : IN std_logic;
      user_w_write_8_data : OUT std_logic_vector(7 DOWNTO 0);
      user_w_write_8_open : OUT std_logic;
      user_r_audio_rden : OUT std_logic;
      user_r_audio_empty : IN std_logic;
      user_r_audio_data : IN std_logic_vector(31 DOWNTO 0);
      user_r_audio_eof : IN std_logic;
      user_r_audio_open : OUT std_logic;
      user_w_audio_wren : OUT std_logic;
      user_w_audio_full : IN std_logic;
      user_w_audio_data : OUT std_logic_vector(31 DOWNTO 0);
      user_w_audio_open : OUT std_logic;
      user_r_smb_rden : OUT std_logic;
      user_r_smb_empty : IN std_logic;
      user_r_smb_data : IN std_logic_vector(7 DOWNTO 0);
      user_r_smb_eof : IN std_logic;
      user_r_smb_open : OUT std_logic;
      user_w_smb_wren : OUT std_logic;
      user_w_smb_full : IN std_logic;
      user_w_smb_data : OUT std_logic_vector(7 DOWNTO 0);
      user_w_smb_open : OUT std_logic;
      user_clk : OUT std_logic;
      user_wren : OUT std_logic;
      user_wstrb : OUT std_logic_vector(3 DOWNTO 0);
      user_rden : OUT std_logic;
      user_rd_data : IN std_logic_vector(31 DOWNTO 0);
      user_wr_data : OUT std_logic_vector(31 DOWNTO 0);
      user_addr : OUT std_logic_vector(31 DOWNTO 0);
      user_irq : IN std_logic);
  end component;

  component fifo_8x2048
    port (
      clk: IN std_logic;
      srst: IN std_logic;
      din: IN std_logic_VECTOR(7 downto 0);
      wr_en: IN std_logic;
      rd_en: IN std_logic;
      dout: OUT std_logic_VECTOR(7 downto 0);
      full: OUT std_logic;
      empty: OUT std_logic);
  end component;

  component fifo_32x512
    port (
      clk: IN std_logic;
      srst: IN std_logic;
      din: IN std_logic_VECTOR(31 downto 0);
      wr_en: IN std_logic;
      rd_en: IN std_logic;
      dout: OUT std_logic_VECTOR(31 downto 0);
      full: OUT std_logic;
      empty: OUT std_logic);
  end component;

  component i2s_audio
    port (
      bus_clk : IN std_logic;
      clk_100 : IN std_logic;
      quiesce : IN std_logic;
      audio_mclk : OUT std_logic;
      audio_dac : OUT std_logic;
      audio_adc : IN std_logic;
      audio_bclk : IN std_logic;
      audio_lrclk : IN std_logic;
      user_r_audio_rden : IN std_logic;
      user_r_audio_empty : OUT std_logic;
      user_r_audio_data : OUT std_logic_vector(31 DOWNTO 0);
      user_r_audio_eof : OUT std_logic;
      user_r_audio_open : IN std_logic;
      user_w_audio_wren : IN std_logic;
      user_w_audio_full : OUT std_logic;
      user_w_audio_data : IN std_logic_vector(31 DOWNTO 0);
      user_w_audio_open : IN std_logic);
  end component;

  component smbus
    port (
      bus_clk : IN std_logic;
      quiesce : IN std_logic;
      smb_sclk : OUT std_logic;
      smb_sdata : INOUT std_logic;
      smbus_addr : OUT std_logic_vector(1 DOWNTO 0);
      user_r_smb_rden : IN std_logic;
      user_r_smb_empty : OUT std_logic;
      user_r_smb_data : OUT std_logic_vector(7 DOWNTO 0);
      user_r_smb_eof : OUT std_logic;
      user_r_smb_open : IN std_logic;
      user_w_smb_wren : IN std_logic;
      user_w_smb_full : OUT std_logic;
      user_w_smb_data : IN std_logic_vector(7 DOWNTO 0);
      user_w_smb_open : IN std_logic);
  end component;

-- Synplicity black box declaration
  attribute syn_black_box : boolean;
  attribute syn_black_box of fifo_32x512: component is true;
  attribute syn_black_box of fifo_8x2048: component is true;

  type demo_mem is array(0 TO 31) of std_logic_vector(7 DOWNTO 0);
  signal demoarray : demo_mem;
  signal litearray0 : demo_mem;
  signal litearray1 : demo_mem;
  signal litearray2 : demo_mem;
  signal litearray3 : demo_mem;
  
  signal bus_clk :  std_logic;
  signal quiesce : std_logic;

  signal reset_8 : std_logic;
  signal reset_32 : std_logic;

  signal ram_addr : integer range 0 to 31;
  signal lite_addr : integer range 0 to 31;
    
  signal user_r_mem_8_rden :  std_logic;
  signal user_r_mem_8_empty :  std_logic;
  signal user_r_mem_8_data :  std_logic_vector(7 DOWNTO 0);
  signal user_r_mem_8_eof :  std_logic;
  signal user_r_mem_8_open :  std_logic;
  signal user_w_mem_8_wren :  std_logic;
  signal user_w_mem_8_full :  std_logic;
  signal user_w_mem_8_data :  std_logic_vector(7 DOWNTO 0);
  signal user_w_mem_8_open :  std_logic;
  signal user_mem_8_addr :  std_logic_vector(4 DOWNTO 0);
  signal user_mem_8_addr_update :  std_logic;
  signal user_r_read_32_rden :  std_logic;
  signal user_r_read_32_empty :  std_logic;
  signal user_r_read_32_data :  std_logic_vector(31 DOWNTO 0);
  signal user_r_read_32_eof :  std_logic;
  signal user_r_read_32_open :  std_logic;
  signal user_r_read_8_rden :  std_logic;
  signal user_r_read_8_empty :  std_logic;
  signal user_r_read_8_data :  std_logic_vector(7 DOWNTO 0);
  signal user_r_read_8_eof :  std_logic;
  signal user_r_read_8_open :  std_logic;
  signal user_w_write_32_wren :  std_logic;
  signal user_w_write_32_full :  std_logic;
  signal user_w_write_32_data :  std_logic_vector(31 DOWNTO 0);
  signal user_w_write_32_open :  std_logic;
  signal user_w_write_8_wren :  std_logic;
  signal user_w_write_8_full :  std_logic;
  signal user_w_write_8_data :  std_logic_vector(7 DOWNTO 0);
  signal user_w_write_8_open :  std_logic;
  signal user_r_audio_rden :  std_logic;
  signal user_r_audio_empty :  std_logic;
  signal user_r_audio_data :  std_logic_vector(31 DOWNTO 0);
  signal user_r_audio_eof :  std_logic;
  signal user_r_audio_open :  std_logic;
  signal user_w_audio_wren :  std_logic;
  signal user_w_audio_full :  std_logic;
  signal user_w_audio_data :  std_logic_vector(31 DOWNTO 0);
  signal user_w_audio_open :  std_logic;
  signal user_r_smb_rden :  std_logic;
  signal user_r_smb_empty :  std_logic;
  signal user_r_smb_data :  std_logic_vector(7 DOWNTO 0);
  signal user_r_smb_eof :  std_logic;
  signal user_r_smb_open :  std_logic;
  signal user_w_smb_wren :  std_logic;
  signal user_w_smb_full :  std_logic;
  signal user_w_smb_data :  std_logic_vector(7 DOWNTO 0);
  signal user_w_smb_open :  std_logic;
  signal user_clk :  std_logic;
  signal user_wren :  std_logic;
  signal user_wstrb :  std_logic_vector(3 DOWNTO 0);
  signal user_rden :  std_logic;
  signal user_rd_data :  std_logic_vector(31 DOWNTO 0);
  signal user_wr_data :  std_logic_vector(31 DOWNTO 0);
  signal user_addr :  std_logic_vector(31 DOWNTO 0);
  signal user_irq :  std_logic;

  -- Note that none of the ARM processor's direct connections to pads is
  -- defined as I/O on this module. Normally, they should be connected
  -- as toplevel ports here, but that confuses Vivado 2013.4 to think that
  -- some of these ports are real I/Os, causing an implementation failure.
  -- This detachment results in a lot of warnings during synthesis and
  -- implementation, but has no practical significance, as these pads are
  -- completely unrelated to the FPGA bitstream.

  -- signal PS_CLK :  std_logic;
  -- signal PS_PORB :  std_logic;
  -- signal PS_SRSTB :  std_logic;
  signal DDR_Addr : std_logic_vector(14 DOWNTO 0);
  signal DDR_BankAddr : std_logic_vector(2 DOWNTO 0);
  signal DDR_CAS_n : std_logic;
  signal DDR_CKE : std_logic;
  signal DDR_CS_n : std_logic;
  signal DDR_Clk : std_logic;
  signal DDR_Clk_n : std_logic;
  signal DDR_DM : std_logic_vector(3 DOWNTO 0);
  signal DDR_DQ : std_logic_vector(31 DOWNTO 0);
  signal DDR_DQS : std_logic_vector(3 DOWNTO 0);
  signal DDR_DQS_n : std_logic_vector(3 DOWNTO 0);
  signal DDR_DRSTB : std_logic;
  signal DDR_ODT : std_logic;
  signal DDR_RAS_n : std_logic;
  signal DDR_VRN : std_logic;
  signal DDR_VRP : std_logic;
  signal MIO : std_logic_vector(53 DOWNTO 0);
  signal DDR_WEB : std_logic;

  ---- User defined components and signals

  component new_latch is
	Port ( d1 : in STD_LOGIC;
	       d2 : in STD_LOGIC;
	       d_ctl : in STD_LOGIC;
	       train_en : in STD_LOGIC;
	       pix_clk : in STD_LOGIC;
	       clk : in STD_LOGIC;
	       rst : in STD_LOGIC;
	       out_latch : out STD_LOGIC := '0';
	       locked : out STD_LOGIC := '0';
	       q1 : out STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
	       q2 : out STD_LOGIC_VECTOR (7 downto 0) := (others => '0'));
  end component;

  signal g_rst : STD_LOGIC; -- Global reset
  signal d1, d2, d_ctl : STD_LOGIC;
  signal train_en, pix_clk, lvds_clk, ddr_rst : STD_LOGIC;
  signal ddr_latch, ddr_locked : STD_LOGIC;
  signal q1, q2 : STD_LOGIC_VECTOR (7 downto 0);
  signal extended_buffer : STD_LOGIC_VECTOR (31 downto 0);
  signal fifo_latch, ddr_latched, fifo_full_1, fifo_full_2 : STD_LOGIC;

  signal pix1, pix2, pix_ctl : STD_LOGIC_VECTOR (9 downto 0);
  signal fakesensor_1, fakesensor_2, fakesensor_ctl : STD_LOGIC;
  signal reset_request : STD_LOGIC;

  -- Sensor control signals
  signal frame_req, t_exp1, trigger : STD_LOGIC;

  signal test_counter : integer := 0;
  
begin

	-- rst high until system started
	g_rst <= not quiesce;

-- 	TRIGGER_LATCH : process(bus_clk)
-- 		variable trig_counter : integer := 0;
-- 	begin
-- 
-- 		if bus_clk'EVENT and bus_clk = '0' then
-- 			if trig_counter < 0 then
-- 				trig_counter := 0;
-- 				trigger <= '0';
-- 			elsif trig_counter >= 100000000 then
-- 				trig_counter := 0;
-- 				trigger <= '1';
-- 			else
-- 				trig_counter := trig_counter + 1;
-- 				trigger <= '0';
-- 			end if;
-- 		end if;
-- 
-- 	end process; -- TRIGGER_LATCH


  CLOCK_DIVIDER : process(bus_clk, g_rst)
	  variable counter_5mhz, counter_25mhz : integer;
  begin

	  if g_rst = '1' then
		  -- Reset counter/divider
		  counter_5mhz := 0;
		  counter_25mhz := 0;
		  trigger <= '0';
	  else

		  -- Rising edge of clk_100
		  if bus_clk'EVENT and bus_clk = '0' then

			  -- Increment counters

			  -- Divide by 20 (toggle every 10) for 5MHz clock
			  -- if counter_5mhz >= 10 then
			  if counter_5mhz < 0 then
				  counter_5mhz := 0;
				  trigger <= '0';
			  elsif counter_5mhz > 1000000 then
				  counter_5mhz := 0;
				  pix_clk <= not pix_clk;
				  trigger <= '1';
			  else
				  counter_5mhz := counter_5mhz + 1;
				  trigger <= '0';
			  end if;

			  -- Divide by 4 (toggle every 2) for 25MHz clock
			  -- if counter_25mhz >= 2 then
			  if counter_25mhz < 0 then
				  counter_25mhz := 0;
				  trigger <= '0';
			  elsif counter_25mhz > 200000 then
				  counter_25mhz := 0;
				  lvds_clk <= not lvds_clk;
				  trigger <= '1';
			  else
				  counter_25mhz := counter_25mhz + 1;
				  trigger <= '0';
			  end if;

		  end if;
	  end if;
  end process; -- CLOCK_DIVIDER

--   SYSTEM_RESET : process(clk_100, reset_request)
-- 	  variable rst_counter : integer := 0;
--   begin
-- 
-- 	  -- Rising edge of reset_request
-- 	  if reset_request'EVENT and reset_request = '1' then
-- 		  -- Enable global logic reset
-- 		  g_rst <= '1';
-- 		  -- Reset counter
-- 		  rst_counter := 0;
-- 	  end if;
-- 
-- 	  -- Rising edge of clk_100
-- 	  if g_rst = '1' and clk_100'EVENT and clk_100 = '1' then
-- 		  rst_counter := rst_counter + 1;
-- 		  -- Leave g_rst high for 10ms
-- 		  if rst_counter >= 1000000 then
-- 			  rst_counter := 0;
-- 			  g_rst <= '0';
-- 		  end if;
-- 	  end if;
-- 
--   end process; -- SYSTEM_RESET

  EXECUTION : process(pix_clk, g_rst)
	  variable pix_count : integer;
  begin

	  if g_rst = '1' then
		  pix_count := 0;
		  train_en <= '0';
		  reset_request <= '0';
	  else

		  -- Rising edge of pix_clk
		  if pix_clk'EVENT and pix_clk = '1' then
			  pix_count := pix_count + 1;

			  if pix_count < 1000 then

				  train_en <= '1';

				  -- Training data
				  pix1 <= "0001010101";
				  pix2 <= "0001010101";
				  pix_ctl <= "1000000000";

			  elsif pix_count < ((2048*1088/2) + 1000) then

				  train_en <= '0';

				  -- "Actual" data, the character 'G'
				  -- LSBs on data should be ignored
				  pix1 <= "0100011110";
				  pix2 <= "0100011101";
				  pix_ctl <= "1000000111";

			  else

				  -- Training data again
				  pix1 <= "0001010101";
				  pix2 <= "0001010101";
				  pix_ctl <= "1000000000";

			  end if;

			  -- After 10 seconds reset counter
			  if pix_count >= 50000000 then
				  pix_count := 0;
			  	  -- Request a reset from a different process
				  reset_request <= '1';
			  end if;

		  end if;

	  end if;

  end process; -- EXECUTION

  SERIALIZE : process(lvds_clk, g_rst)
	  variable index : integer := 0;
  begin

	  if g_rst = '1' then -- Reset
		  index := 0;
	  else

		  -- Rising edge of lvds_clk
		  if lvds_clk'EVENT and lvds_clk = '0' then

			  fakesensor_1 <= pix1(index);
			  fakesensor_2 <= pix2(index);
			  fakesensor_ctl <= pix_ctl(index);

			  index := index + 1;
			  if index > 9 then
				  index := 0;
			  end if;

		  end if;
	  end if;
  end process; -- SERIALIZE;

--  fakesensor_1 <= '0';
--  fakesensor_2 <= '0';
--  fakesensor_ctl <= '0';

  d1 <= fakesensor_1;
  d2 <= fakesensor_2;
  d_ctl <= fakesensor_ctl;

  ------ Interface

  -- Temporarily
  ddr_rst <= g_rst;

  DDR_INST : new_latch port map ( d1 => d1,
				  d2 => d2,
				  d_ctl => d_ctl,
				  train_en => train_en,
				  pix_clk => pix_clk,
				  clk => lvds_clk,
				  rst => ddr_rst,
				  out_latch => ddr_latch,
				  locked => ddr_locked,
				  q1 => q1,
				  q2 => q2);

  LATCH_DDR : process(pix_clk, ddr_latch, bus_clk, clk_100)
	  variable clk_counter, wait_counter, new_counter : integer := 0;
	  variable set_latch, start_wait : boolean := false;
  begin

 	  -- Rising edge of pix_clk
 	  if pix_clk'EVENT and pix_clk = '1' then
		  set_latch := true;
 	  end if;

	  -- Falling edge of bus_clk
	  if bus_clk'EVENT and bus_clk = '0' then
		  if set_latch then
 			  fifo_latch <= '1';
			  set_latch := false;
		  else
			  fifo_latch <= '0';
 		  end if;
 	  end if;

  end process; -- LATCH_DDR

  -- Using the 32 bit FIFO to transmit single bytes isn't efficient, but it 
  -- keeps things consistent with the other FIFO and it's easy to ditch the rest
  -- of the data in software
  -- extended_buffer <= "000000000000000000000000" & q1;
  -- extended_buffer <= std_logic_vector(to_unsigned(test_counter, 32));
  extended_buffer <= "01101011" & "00110101" & "01011100" & "01010111";
  fifo_32 : fifo_32x512
    port map(
      clk        => bus_clk,
      srst       => reset_32,
      din        => extended_buffer,
      wr_en      => trigger,
      rd_en      => user_r_read_32_rden,
      dout       => user_r_read_32_data,
      full       => fifo_full_1,
      empty      => user_r_read_32_empty
      );

  -- reset_32 <= not (user_w_write_32_open or user_r_read_32_open);
    reset_32 <= '0'; -- For now

    user_r_read_32_eof <= '0'; -- For now
  
--  8-bit loopback

  fifo_8 : fifo_8x2048
    port map(
      clk        => bus_clk,
      srst       => reset_8,
      -- din        => q2,
      din	 => extended_buffer (7 downto 0),
      -- wr_en      => fifo_latch,
      wr_en	 => trigger,
      rd_en      => user_r_read_8_rden,
      dout       => user_r_read_8_data,
      full       => fifo_full_2,
      empty      => user_r_read_8_empty
      );

    -- reset_8 <= not (user_w_write_8_open or user_r_read_8_open);
    reset_8 <= '0'; -- For now

    user_r_read_8_eof <= '0'; -- For now

--     EOF_8 : process (user_r_read_8_eof)
--     begin


--  32-bit loopback

--   fifo_32 : fifo_32x512
--     port map(
--       clk        => bus_clk,
--       srst       => reset_32,
--       din        => user_w_write_32_data,
--       wr_en      => user_w_write_32_wren,
--       rd_en      => user_r_read_32_rden,
--       dout       => user_r_read_32_data,
--       full       => user_w_write_32_full,
--       empty      => user_r_read_32_empty
--       );
-- 
--   reset_32 <= not (user_w_write_32_open or user_r_read_32_open);
-- 
--   user_r_read_32_eof <= '0';

  audio_ins : i2s_audio
    port map(
      bus_clk => bus_clk,
      clk_100 => clk_100,
      quiesce => quiesce,
      audio_mclk => audio_mclk,
      audio_dac => audio_dac,
      audio_adc => audio_adc,
      audio_bclk => audio_bclk,
      audio_lrclk => audio_lrclk,
      user_r_audio_rden => user_r_audio_rden,
      user_r_audio_empty => user_r_audio_empty,
      user_r_audio_data => user_r_audio_data,
      user_r_audio_eof => user_r_audio_eof,
      user_r_audio_open => user_r_audio_open,
      user_w_audio_wren => user_w_audio_wren,
      user_w_audio_full => user_w_audio_full,
      user_w_audio_data => user_w_audio_data,
      user_w_audio_open => user_w_audio_open
      );

  smbus_ins : smbus
    port map(
      bus_clk => bus_clk,
      quiesce => quiesce,
      smb_sclk => smb_sclk,
      smb_sdata => smb_sdata,
      smbus_addr => smbus_addr,
      user_r_smb_rden => user_r_smb_rden,
      user_r_smb_empty => user_r_smb_empty,
      user_r_smb_data => user_r_smb_data,
      user_r_smb_eof => user_r_smb_eof,
      user_r_smb_open => user_r_smb_open,
      user_w_smb_wren => user_w_smb_wren,
      user_w_smb_full => user_w_smb_full,
      user_w_smb_data => user_w_smb_data,
      user_w_smb_open => user_w_smb_open
      );
  
  xillybus_ins : xillybus
    port map (
      -- Ports related to /dev/xillybus_mem_8
      -- FPGA to CPU signals:
      user_r_mem_8_rden => user_r_mem_8_rden,
      user_r_mem_8_empty => user_r_mem_8_empty,
      user_r_mem_8_data => user_r_mem_8_data,
      user_r_mem_8_eof => user_r_mem_8_eof,
      user_r_mem_8_open => user_r_mem_8_open,
      -- CPU to FPGA signals:
      user_w_mem_8_wren => user_w_mem_8_wren,
      user_w_mem_8_full => user_w_mem_8_full,
      user_w_mem_8_data => user_w_mem_8_data,
      user_w_mem_8_open => user_w_mem_8_open,
      -- Address signals:
      user_mem_8_addr => user_mem_8_addr,
      user_mem_8_addr_update => user_mem_8_addr_update,

      -- Ports related to /dev/xillybus_read_32
      -- FPGA to CPU signals:
      user_r_read_32_rden => user_r_read_32_rden,
      user_r_read_32_empty => user_r_read_32_empty,
      user_r_read_32_data => user_r_read_32_data,
      user_r_read_32_eof => user_r_read_32_eof,
      user_r_read_32_open => user_r_read_32_open,

      -- Ports related to /dev/xillybus_read_8
      -- FPGA to CPU signals:
      user_r_read_8_rden => user_r_read_8_rden,
      user_r_read_8_empty => user_r_read_8_empty,
      user_r_read_8_data => user_r_read_8_data,
      user_r_read_8_eof => user_r_read_8_eof,
      user_r_read_8_open => user_r_read_8_open,

      -- Ports related to /dev/xillybus_write_32
      -- CPU to FPGA signals:
      user_w_write_32_wren => user_w_write_32_wren,
      user_w_write_32_full => user_w_write_32_full,
      user_w_write_32_data => user_w_write_32_data,
      user_w_write_32_open => user_w_write_32_open,

      -- Ports related to /dev/xillybus_write_8
      -- CPU to FPGA signals:
      user_w_write_8_wren => user_w_write_8_wren,
      user_w_write_8_full => user_w_write_8_full,
      user_w_write_8_data => user_w_write_8_data,
      user_w_write_8_open => user_w_write_8_open,

      -- Ports related to Xillybus Lite
      user_clk => user_clk,
      user_wren => user_wren,
      user_wstrb => user_wstrb,
      user_rden => user_rden,
      user_rd_data => user_rd_data,
      user_wr_data => user_wr_data,
      user_addr => user_addr,
      user_irq => user_irq,

      -- Ports related to /dev/xillybus_audio
      -- FPGA to CPU signals:
      user_r_audio_rden => user_r_audio_rden,
      user_r_audio_empty => user_r_audio_empty,
      user_r_audio_data => user_r_audio_data,
      user_r_audio_eof => user_r_audio_eof,
      user_r_audio_open => user_r_audio_open,
      -- CPU to FPGA signals:
      user_w_audio_wren => user_w_audio_wren,
      user_w_audio_full => user_w_audio_full,
      user_w_audio_data => user_w_audio_data,
      user_w_audio_open => user_w_audio_open,

      -- Ports related to /dev/xillybus_smb
      -- FPGA to CPU signals:
      user_r_smb_rden => user_r_smb_rden,
      user_r_smb_empty => user_r_smb_empty,
      user_r_smb_data => user_r_smb_data,
      user_r_smb_eof => user_r_smb_eof,
      user_r_smb_open => user_r_smb_open,
      -- CPU to FPGA signals:
      user_w_smb_wren => user_w_smb_wren,
      user_w_smb_full => user_w_smb_full,
      user_w_smb_data => user_w_smb_data,
      user_w_smb_open => user_w_smb_open,

      -- General signals
      PS_CLK => PS_CLK,
      PS_PORB => PS_PORB,
      PS_SRSTB => PS_SRSTB,
      clk_100 => clk_100,
      otg_oc => otg_oc,
      DDR_Addr => DDR_Addr,
      DDR_BankAddr => DDR_BankAddr,
      DDR_CAS_n => DDR_CAS_n,
      DDR_CKE => DDR_CKE,
      DDR_CS_n => DDR_CS_n,
      DDR_Clk => DDR_Clk,
      DDR_Clk_n => DDR_Clk_n,
      DDR_DM => DDR_DM,
      DDR_DQ => DDR_DQ,
      DDR_DQS => DDR_DQS,
      DDR_DQS_n => DDR_DQS_n,
      DDR_DRSTB => DDR_DRSTB,
      DDR_ODT => DDR_ODT,
      DDR_RAS_n => DDR_RAS_n,
      DDR_VRN => DDR_VRN,
      DDR_VRP => DDR_VRP,
      MIO => MIO,
      PS_GPIO => PS_GPIO,
      DDR_WEB => DDR_WEB,
      GPIO_LED => GPIO_LED,
      bus_clk => bus_clk,
      quiesce => quiesce,
      vga4_blue => vga4_blue,
      vga4_green => vga4_green,
      vga4_red => vga4_red,
      vga_hsync => vga_hsync,
      vga_vsync => vga_vsync
  );

  -- Xillybus Lite
  
  user_irq <= '0'; -- No interrupts for now

  lite_addr <= conv_integer(user_addr(6 DOWNTO 2));

  process (user_clk)
  begin
    if (user_clk'event and user_clk = '1') then
      if (user_wstrb(0) = '1') then 
        litearray0(lite_addr) <= user_wr_data(7 DOWNTO 0);
      end if;

      if (user_wstrb(1) = '1') then 
        litearray1(lite_addr) <= user_wr_data(15 DOWNTO 8);
      end if;

      if (user_wstrb(2) = '1') then 
        litearray2(lite_addr) <= user_wr_data(23 DOWNTO 16);
      end if;

      if (user_wstrb(3) = '1') then 
        litearray3(lite_addr) <= user_wr_data(31 DOWNTO 24);
      end if;

      if (user_rden = '1') then
        user_rd_data <= litearray3(lite_addr) & litearray2(lite_addr) &
                        litearray1(lite_addr) & litearray0(lite_addr);
      end if;
    end if;
  end process;
  
--  A simple inferred RAM

  ram_addr <= conv_integer(user_mem_8_addr);
  
  process (bus_clk)
  begin
    if (bus_clk'event and bus_clk = '1') then
      if (user_w_mem_8_wren = '1') then 
        demoarray(ram_addr) <= user_w_mem_8_data;
      end if;
      if (user_r_mem_8_rden = '1') then
        user_r_mem_8_data <= demoarray(ram_addr);
      end if;
    end if;
  end process;

  user_r_mem_8_empty <= '0';
  user_r_mem_8_eof <= '0';
  user_w_mem_8_full <= '0';
end sample_arch;
