----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/03/2015 06:26:56 PM
-- Design Name: 
-- Module Name: FloP_Shifter - Behavioral
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

entity FloP_Shifter_Generic is
    Generic ( expWidth, fracWidth : integer );
    Port ( inputData : in STD_LOGIC_VECTOR ((expWidth+fracWidth) downto 0); 
           shiftAmt : in STD_LOGIC_VECTOR (expWidth-1 downto 0);
           leftRight : in STD_LOGIC;
           outputData : out STD_LOGIC_VECTOR ((expWidth+fracWidth) downto 0) );
end FloP_Shifter_Generic;

architecture Behavioral of FloP_Shifter_Generic is
    
    component Mux_Generic is
        Generic ( dataWidth : integer ); 
        Port ( dataIn1 : in std_logic_vector (dataWidth-1 downto 0);
               dataIn2 : in std_logic_vector (dataWidth-1 downto 0);
               selectIn : in std_logic;
               dataOut : out std_logic_vector (dataWidth-1 downto 0));
    end component;
    
    component Adder_Generic is
        Generic ( dataWidth : integer );
        Port ( num1, num2 : in STD_LOGIC_VECTOR (dataWidth-1 downto 0);
               carryIn : in STD_LOGIC;
               sum : out STD_LOGIC_VECTOR (dataWidth-1 downto 0);
               carryOut, overflow : out STD_LOGIC );
    end component;
    
    component Comparator_Generic is
        Generic ( dataWidth : integer );
        Port ( a, b : in STD_LOGIC_VECTOR (dataWidth-1 downto 0);
               lt, eq, gt : out STD_LOGIC );
    end component;
    
    signal shiftAmtComp, expDiff, muxOut : std_logic_vector (expWidth-1 downto 0);
    signal overflow, eqZero : std_logic;

begin

    TwosComp : Adder_Generic Generic Map ( dataWidth => expWidth )
            Port Map ( num1 => not(shiftAmt), num2 => (others => '0'), carryIn => '1', sum => shiftAmtComp );
    
    leftRightMux : Mux_Generic Generic Map ( dataWidth => expWidth )
            Port Map ( dataIn1 => shiftAmt, dataIn2 => shiftAmtComp, selectIn => leftRight, dataOut => muxOut );
    
    Subtractor : Adder_Generic Generic Map ( dataWidth => expWidth )
            Port Map ( num1 => inputData((expWidth+fracWidth-1) downto (fracWidth)), num2 => muxOut, carryIn => '0',
                   sum => expDiff, overflow => overflow );
    
    Comparator : Comparator_Generic Generic Map ( dataWidth => expWidth )
            Port Map ( a => inputData(expWidth+fracWidth-1 downto fracWidth), b => (others => '0'),
                       eq => eqZero );
    
    OutputMux : Mux_Generic Generic Map ( dataWidth => expWidth+fracWidth+1 )
            Port Map ( dataIn1 => inputData(expWidth+fracWidth) & expDiff & inputData(fracWidth-1 downto 0), 
                       dataIn2 => (others => '0'), selectIn => eqZero, dataOut => outputData );

end Behavioral;
