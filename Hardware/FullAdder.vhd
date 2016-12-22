----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/27/2015 08:43:40 PM
-- Design Name: 
-- Module Name: FullAdder - Behavioral
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

entity FullAdder is
    Port ( num1 : in STD_LOGIC;
           num2 : in STD_LOGIC;
           carryIn : in STD_LOGIC;
           sum : out STD_LOGIC;
           carryOut : out STD_LOGIC);
end FullAdder;

architecture Behavioral of FullAdder is

begin
    sum <= num1 xor num2 xor carryIn;
    carryOut <= (num1 and num2) or (num1 and carryIn) or (num2 and carryIn);
end Behavioral;
