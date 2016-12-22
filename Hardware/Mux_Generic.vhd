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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


-- TODO: Make more generic, allow for more than two vector inputs. Need an array of vectors or something.

entity Mux_Generic is
    Generic ( dataWidth : integer ); --selectWidth : integer);
    Port ( dataIn1 : in std_logic_vector (dataWidth-1 downto 0);
           dataIn2 : in std_logic_vector (dataWidth-1 downto 0);
--           selectIn : in std_logic_vector (selectWidth-1 downto 0);
           selectIn : in std_logic;
           dataOut : out std_logic_vector (dataWidth-1 downto 0));
end Mux_Generic;

architecture Behavioral of Mux_Generic is
begin
--    dataOut <= dataIn(conv_integer(selectIn));
--    dataOut <= (dataIn1 and not(selectIn)) or (dataIn2 and selectIn);
    dataOut <= dataIn1 when selectIn = '0' else dataIn2;
end Behavioral;
