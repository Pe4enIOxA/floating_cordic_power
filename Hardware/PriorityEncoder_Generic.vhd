----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/16/2015 11:18:23 PM
-- Design Name: 
-- Module Name: PriorityEncoder_Generic - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PriorityEncoder_Generic is
    Generic ( inputWidth : integer; outputWidth : integer );
    Port ( input : in STD_LOGIC_VECTOR (inputWidth-1 downto 0);
           enable : in STD_LOGIC;
           output : out STD_LOGIC_VECTOR (outputWidth-1 downto 0) );
end PriorityEncoder_Generic;

architecture Behavioral of PriorityEncoder_Generic is

begin

    p1 : process(input, enable) begin
        if enable = '1' then
            for i in inputWidth-1 downto 0 loop
                if input(i) = '1' then
                    output <= std_logic_vector(to_unsigned(inputWidth-1-i, outputWidth));
                    exit;
                end if;
            end loop;
        else
            output <= (others => 'U');
        end if;
    end process;

end Behavioral;
