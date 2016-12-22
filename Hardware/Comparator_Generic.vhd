----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/27/2015 07:22:47 PM
-- Design Name: 
-- Module Name: Comparator_Generic - Behavioral
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

entity Comparator_Generic is
    Generic ( dataWidth : integer );
    Port ( a, b : in std_logic_vector(dataWidth-1 downto 0);
           lt, eq, gt : out std_logic ); 
end Comparator_Generic;

architecture Behavioral of Comparator_Generic is
begin
    
    p1 : process(a, b) begin
        if a < b then
            lt <= '1'; eq <= '0'; gt <= '0';
        elsif a = b then
            lt <= '0'; eq <= '1'; gt <= '0';
        else
            lt <= '0'; eq <= '0'; gt <= '1';
        end if;
    end process;

end Behavioral;
