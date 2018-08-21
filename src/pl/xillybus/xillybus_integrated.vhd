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

architecture sample_arch of template is
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
			     user_r_cmos_rh_32_rden : OUT std_logic;
			     user_r_cmos_rh_32_empty : IN std_logic;
			     user_r_cmos_rh_32_data : IN std_logic_vector(31 DOWNTO 0);
			     user_r_cmos_rh_32_eof : IN std_logic;
			     user_r_cmos_rh_32_open : OUT std_logic;
			     user_r_cmos_rl_32_rden : OUT std_logic;
			     user_r_cmos_rl_32_empty : IN std_logic;
			     user_r_cmos_rl_32_data : IN std_logic_vector(31 DOWNTO 0);
			     user_r_cmos_rl_32_eof : IN std_logic;
			     user_r_cmos_rl_32_open : OUT std_logic;
			     user_r_spi_r_8_rden : OUT std_logic;
			     user_r_spi_r_8_empty : IN std_logic;
			     user_r_spi_r_8_data : IN std_logic_vector(7 DOWNTO 0);
			     user_r_spi_r_8_eof : IN std_logic;
			     user_r_spi_r_8_open : OUT std_logic;
			     user_w_spi_w_8_wren : OUT std_logic;
			     user_w_spi_w_8_full : IN std_logic;
			     user_w_spi_w_8_data : OUT std_logic_vector(7 DOWNTO 0);
			     user_w_spi_w_8_open : OUT std_logic;
			     user_clk : OUT std_logic;
			     user_wren : OUT std_logic;
			     user_rden : OUT std_logic;
			     user_wstrb : OUT std_logic_vector(3 DOWNTO 0);
			     user_addr : OUT std_logic_vector(31 DOWNTO 0);
			     user_rd_data : IN std_logic_vector(31 DOWNTO 0);
			     user_wr_data : OUT std_logic_vector(31 DOWNTO 0);
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

  -- Synplicity black box declaration
	attribute syn_black_box : boolean;
	attribute syn_black_box of fifo_32x512: component is true;
	attribute syn_black_box of fifo_8x2048: component is true;

	signal bus_clk :  std_logic;
	signal quiesce : std_logic;
	signal user_r_cmos_rh_32_rden :  std_logic;
	signal user_r_cmos_rh_32_empty :  std_logic;
	signal user_r_cmos_rh_32_data :  std_logic_vector(31 DOWNTO 0);
	signal user_r_cmos_rh_32_eof :  std_logic;
	signal user_r_cmos_rh_32_open :  std_logic;
	signal user_r_cmos_rl_32_rden :  std_logic;
	signal user_r_cmos_rl_32_empty :  std_logic;
	signal user_r_cmos_rl_32_data :  std_logic_vector(31 DOWNTO 0);
	signal user_r_cmos_rl_32_eof :  std_logic;
	signal user_r_cmos_rl_32_open :  std_logic;
	signal user_r_spi_r_8_rden :  std_logic;
	signal user_r_spi_r_8_empty :  std_logic;
	signal user_r_spi_r_8_data :  std_logic_vector(7 DOWNTO 0);
	signal user_r_spi_r_8_eof :  std_logic;
	signal user_r_spi_r_8_open :  std_logic;
	signal user_w_spi_w_8_wren :  std_logic;
	signal user_w_spi_w_8_full :  std_logic;
	signal user_w_spi_w_8_data :  std_logic_vector(7 DOWNTO 0);
	signal user_w_spi_w_8_open :  std_logic;
	signal user_clk :  std_logic;
	signal user_wren :  std_logic;
	signal user_rden :  std_logic;
	signal user_wstrb :  std_logic_vector(3 DOWNTO 0);
	signal user_addr :  std_logic_vector(31 DOWNTO 0);
	signal user_rd_data :  std_logic_vector(31 DOWNTO 0);
	signal user_wr_data :  std_logic_vector(31 DOWNTO 0);

	signal reset_8 : std_logic;
	signal reset_32 : std_logic;

  -- Not included in template for some reason
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


  -- User defined components and signals

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

	signal d1, d2, d_ctl : std_logic;
	signal train_en, pix_clk, clk, rst : std_logic;
	signal out_latch, locked, q1, q2 : std_logic;

	signal fifo_latch : std_logic;

-- End of user defined section


begin
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


  -- User DDR interface
	DDR_INS : new_latch port map ( d1 => d1,
				       d2 => d2,
				       d_ctl => d_ctl,
				       train_en => train_en,
				       pix_clk => pix_clk,
				       clk => clk,
				       rst => rst,
				       out_latch => out_latch,
				       locked => locked,
				       q1 => q1,
				       q2 => q2);


	-- Managing the latching from the DDR interface to align with FIFO logic
	-- EOF signal should go high if ever data is being produced faster than 
	-- it is begin emptied. You can tell if this is the case because the 
	-- latch is still high by the time a bus_clk pulse occurs or the FIFO
	-- becomes full. Details about this are in the Xillybus docs
	-- The EOF signal should be cleared when the files are closed
	LATCH_EOF : process (bus_clk, out_latch, user_r_cmos_rh_32_open, user_r_cmos_rl_32_open)
	begin

		if bus_clk'EVENT and bus_clk = '1' then
			if fifo_latch = '1' then
				fifo_latch <= '0';
			end if;
		end if;

		if out_latch'EVENT and out_latch = '1' then
			if fifo_latch = '1' then
				-- Send EOF signal
				user_r_cmos_rh_32_eof <= '1';
				user_r_cmos_rl_32_eof <= '1';
			else
				fifo_latch <= '1';
			end if;
		end if;

		-- If files go from open to closed, reset EOF
		if user_r_cmos_rh_32_open'EVENT and user_r_cmos_rh_32_open = '0' then
			user_r_cmos_rh_32_eof <= '0';
		end if;
		if user_r_cmos_rl_32_open'EVENT and user_r_cmos_rl_32_open = '0' then
			user_r_cmos_rl_32_eof <= '0';
		end if;

	end process; -- LATCH_SET_RESET



  --  32-bit FIFO buffer

		fifo_32 : fifo_32x512
		port map(
				clk   => bus_clk,
				srst  => reset_32,
				din   => user_w_write_32_data,
				wr_en => user_w_write_32_wren,
				rd_en => user_r_read_32_rden,
				dout  => user_r_read_32_data,
				full  => user_w_write_32_full,
				empty => user_r_read_32_empty
			);

		reset_32 <= not (user_w_write_32_open or user_r_read_32_open);

		user_r_read_32_eof <= '0';

  --  8-bit loopback

		fifo_8 : fifo_8x2048
		port map(
				clk   => bus_clk,
				srst  => reset_8,
				din   => user_w_write_8_data,
				wr_en => user_w_write_8_wren,
				rd_en => user_r_read_8_rden,
				dout  => user_r_read_8_data,
				full  => user_w_write_8_full,
				empty => user_r_read_8_empty
			);

		reset_8 <= not (user_w_write_8_open or user_r_read_8_open);

		user_r_read_8_eof <= '0';

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

	end sample_arch;
