------------------------------------------------------------------------------
-- File:
--	system.vhd
--
-- Description:
--	This is the fully integrated system for the Zynq PL. It includes the 
--	Xillybus interface to the PS, DDR interface to the CMOS sensor, and 
--	FIFO buffers connected between them.
--
--	Items left to add:
--		UART
--		EOF generation
--
-- Author:
--	David Stockhouse
--
-- Revision 1.0
-- Last edited: 7/24/18
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

architecture Behavioral of system is
  component xillybus
    port (

      -- Possibly change if more needed
      lvds_d1 : in STD_LOGIC;
      lvds_d2 : in STD_LOGIC;
      lvds_ctl : in STD_LOGIC;
      lvds_clk : in STD_LOGIC;
      pix_clk : in STD_LOGIC;


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

  -- User defined component declarations

  component integrated
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
  end component;

  -- User defined signals

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
  xillybus_ins : xillybus
    port map (
      -- Ports related to /dev/xillybus_cmos_rh_32
      -- FPGA to CPU signals:
      user_r_cmos_rh_32_rden => user_r_cmos_rh_32_rden,
      user_r_cmos_rh_32_empty => user_r_cmos_rh_32_empty,
      user_r_cmos_rh_32_data => user_r_cmos_rh_32_data,
      user_r_cmos_rh_32_eof => user_r_cmos_rh_32_eof,
      user_r_cmos_rh_32_open => user_r_cmos_rh_32_open,

      -- Ports related to /dev/xillybus_cmos_rl_32
      -- FPGA to CPU signals:
      user_r_cmos_rl_32_rden => user_r_cmos_rl_32_rden,
      user_r_cmos_rl_32_empty => user_r_cmos_rl_32_empty,
      user_r_cmos_rl_32_data => user_r_cmos_rl_32_data,
      user_r_cmos_rl_32_eof => user_r_cmos_rl_32_eof,
      user_r_cmos_rl_32_open => user_r_cmos_rl_32_open,

      -- Ports related to /dev/xillybus_spi_r_8
      -- FPGA to CPU signals:
      user_r_spi_r_8_rden => user_r_spi_r_8_rden,
      user_r_spi_r_8_empty => user_r_spi_r_8_empty,
      user_r_spi_r_8_data => user_r_spi_r_8_data,
      user_r_spi_r_8_eof => user_r_spi_r_8_eof,
      user_r_spi_r_8_open => user_r_spi_r_8_open,

      -- Ports related to /dev/xillybus_spi_w_8
      -- CPU to FPGA signals:
      user_w_spi_w_8_wren => user_w_spi_w_8_wren,
      user_w_spi_w_8_full => user_w_spi_w_8_full,
      user_w_spi_w_8_data => user_w_spi_w_8_data,
      user_w_spi_w_8_open => user_w_spi_w_8_open,

      -- Ports related to Xillybus Lite
      user_clk => user_clk,
      user_wren => user_wren,
      user_rden => user_rden,
      user_wstrb => user_wstrb,
      user_addr => user_addr,
      user_rd_data => user_rd_data,
      user_wr_data => user_wr_data,
      user_irq => user_irq,

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


  -- Integrated system
  INTEGRATED_INS : integrated port map (
  		lvds_d1 => lvds_d1,
	       lvds_d2 => lvds_d2,
	       lvds_ctl => lvds_ctl,
	       lvds_clk => lvds_clk,
	       pix_clk => pix_clk,
	       rst => ,
	       out_high => user_r_cmos_rh_32_data,
	       out_low => user_r_cmos_rl_32_data,
	       latch => int_lvds_latch,
	       eof => );


--  32-bit loopback

  fifo_32 : fifo_32x512
    port map(
      clk        => bus_clk,
      srst       => reset_32,
      din        => user_w_write_32_data,
      wr_en      => user_w_write_32_wren,
      rd_en      => user_r_read_32_rden,
      dout       => user_r_read_32_data,
      full       => user_w_write_32_full,
      empty      => user_r_read_32_empty
      );

  reset_32 <= not (user_w_write_32_open or user_r_read_32_open);

  user_r_read_32_eof <= '0';
  
--  8-bit loopback

  fifo_8 : fifo_8x2048
    port map(
      clk        => bus_clk,
      srst       => reset_8,
      din        => STD_LOGIC_VECTOR(my_data),
      wr_en      => user_w_write_8_wren,
      rd_en      => user_r_read_8_rden,
      dout       => user_r_read_8_data,
      full       => user_w_write_8_full,
      empty      => user_r_read_8_empty
      );

    reset_8 <= not (user_w_write_8_open or user_r_read_8_open);

    user_r_read_8_eof <= '0';

end Behavioral;

