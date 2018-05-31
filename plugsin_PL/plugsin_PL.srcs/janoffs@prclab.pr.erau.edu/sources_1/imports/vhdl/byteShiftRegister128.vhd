----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/21/2018 10:07:13 PM
-- Design Name: 
-- Module Name: byteShiftRegister128 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_arith.ALL;
library std_logic_unsigned;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity byteShiftRegister128 is
    Port ( D : in STD_LOGIC_VECTOR (7 downto 0);
           Q : out STD_LOGIC_VECTOR (1023 downto 0) := (others => '0');
           clk : in STD_LOGIC;
           rst : in STD_LOGIC);
end byteShiftRegister128;

architecture Behavioral of byteShiftRegister128 is

component byteBuffer
    Port ( D : in STD_LOGIC_VECTOR (7 downto 0);
           Q : out STD_LOGIC_VECTOR (7 downto 0);
           latch : in STD_LOGIC;
           rst : in STD_LOGIC);
end component;

signal inside : STD_LOGIC_VECTOR (1023 downto 0) := (others => '0');

begin

Q <= inside;

SHIFT: for bl in 0 to 127 generate
    
    HIGHBIT: if bl = 0 generate
        BYTE: byteBuffer port map (D => D, Q => inside(1023 downto 1016), latch => clk, rst => rst);
    end generate HIGHBIT;
    
    TYP: if bl > 0 generate 
        BYTE: byteBuffer port map (D => inside((((bl + 1) * 8) - 1) downto (bl * 8)), Q => inside(((bl * 8) - 1) downto ((bl - 1) * 8)), latch => clk, rst => rst);
    end generate TYP;

end generate SHIFT; 


end Behavioral;
