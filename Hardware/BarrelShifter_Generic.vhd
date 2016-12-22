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

entity BarrelShifter_Generic is
  Generic ( dataWidth : integer; shiftWidth : integer );
  Port ( inputData : in std_logic_vector(dataWidth-1 downto 0);
         shiftAmt : in std_logic_vector(shiftWidth-1 downto 0);
         leftRight : in std_logic;
         outputData : out std_logic_vector(dataWidth-1 downto 0));
end BarrelShifter_Generic;

architecture Behavioral of BarrelShifter_Generic is
--    component BarrelShifter_32 is
--        Port ( inputData : in std_logic_vector(51 downto 0);
--                shiftEn, leftRight : in std_logic;
--                outputData : out std_logic_vector(51 downto 0));
--    end component;
--    component BarrelShifter_16 is
--        Port ( inputData : in std_logic_vector(51 downto 0);
--                shiftEn, leftRight : in std_logic;
--                outputData : out std_logic_vector(51 downto 0));
--    end component;
--    component BarrelShifter_8 is
--        Port ( inputData : in std_logic_vector(51 downto 0);
--                shiftEn, leftRight : in std_logic;
--                outputData : out std_logic_vector(51 downto 0));
--        end component;
--    component BarrelShifter_4 is
--        Port ( inputData : in std_logic_vector(51 downto 0);
--                shiftEn, leftRight : in std_logic;
--                outputData : out std_logic_vector(51 downto 0));
--        end component;
--    component BarrelShifter_2 is
--        Port ( inputData : in std_logic_vector(51 downto 0);
--                shiftEn, leftRight : in std_logic;
--                outputData : out std_logic_vector(51 downto 0));
--        end component;
--    component BarrelShifter_1 is
--        Port ( inputData : in std_logic_vector(51 downto 0);
--                shiftEn, leftRight : in std_logic;
--                outputData : out std_logic_vector(51 downto 0));
--    end component;

--    signal ThirtyTwo16, Sixteen8, Eight4, Four2, Two1 : std_logic_vector(51 downto 0);

begin
--    shftr1 : BarrelShifter_32 port map (inputData => inputData, shiftEn => shiftAmt(5), leftRight => leftRight, outputData => ThirtyTwo16);
--    shftr2 : BarrelShifter_16 port map (inputData => ThirtyTwo16, shiftEn => shiftAmt(4), leftRight => leftRight, outputData => Sixteen8);
--    shftr3 : BarrelShifter_8 port map (inputData => Sixteen8, shiftEn => shiftAmt(3), leftRight => leftRight, outputData => Eight4);
--    shftr4 : BarrelShifter_4 port map (inputData => Eight4, shiftEn => shiftAmt(2), leftRight => leftRight, outputData => Four2);
--    shftr5 : BarrelShifter_2 port map (inputData => Four2, shiftEn => shiftAmt(1), leftRight => leftRight, outputData => Two1);
--    shftr6 : BarrelShifter_1 port map (inputData => Two1, shiftEn => shiftAmt(0), leftRight => leftRight, outputData => outputData);
    p1 : process(inputData, shiftAmt, leftRight) begin
        if leftRight = '0' then
--            outputData <= inputData sll 5; --(to_integer(unsigned(shiftAmt))); 
--            outputData <= to_stdlogicvector(shift_left(unsigned(inputData), 
--                                            to_integer(unsigned(shiftAmt))));
            outputData <= std_logic_vector(shift_left(unsigned(inputData), to_integer(unsigned(shiftAmt))));
        else
--            outputData <= inputData srl 5;--(to_integer(unsigned(shiftAmt)));
--            outputData <= to_stdlogicvector(shift_right(unsigned(inputData), 
--                                            to_integer(unsigned(shiftAmt))));
            outputData <= std_logic_vector(shift_right(unsigned(inputData), to_integer(unsigned(shiftAmt))));
        end if;
    end process;

end Behavioral;
