----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/27/2015 08:39:55 PM
-- Design Name: 
-- Module Name: Adder_Generic - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Adder_Generic is
    Generic ( dataWidth : integer );
    Port ( num1 : in STD_LOGIC_VECTOR (dataWidth-1 downto 0);
           num2 : in STD_LOGIC_VECTOR (dataWidth-1 downto 0);
           carryIn : in STD_LOGIC;
           sum : out STD_LOGIC_VECTOR (dataWidth-1 downto 0);
           carryOut : out STD_LOGIC;
           overflow : out STD_LOGIC);
end Adder_Generic;

architecture Behavioral of Adder_Generic is
    component FullAdder is
        Port ( num1 : in STD_LOGIC;
               num2 : in STD_LOGIC;
               carryIn : in STD_LOGIC;
               sum : out STD_LOGIC;
               carryOut : out STD_LOGIC);
    end component;
    
    signal carrySignal : std_logic_vector (dataWidth-1 downto 0);
begin

    carryRipple : for i in 0 to dataWidth-1 generate
    begin
        LSB : if i = 0 generate
        begin
            Adder : component FullAdder port map (num1(0), num2(0), carryIn, sum(0), carrySignal(0));
        end generate LSB;
        remainingAdders : if (i > 0 and i < dataWidth) generate
        begin
            Adder : component FullAdder port map (num1(i), num2(i), carrySignal(i-1), sum(i), carrySignal(i));
        end generate remainingAdders;
    end generate carryRipple;
    
    carryOut <= carrySignal(dataWidth-1);
    overflow <= carrySignal(dataWidth-1) xor carrySignal(dataWidth-2);

end Behavioral;
