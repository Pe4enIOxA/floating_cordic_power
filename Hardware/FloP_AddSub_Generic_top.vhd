----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/02/2015 11:48:29 AM
-- Design Name: 
-- Module Name: SixtyFourBitFPAddSub_toptop - Behavioral
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

entity FloP_AddSub_Generic_top is
    Generic ( expWidth : integer := 11; fracWidth : integer := 52 );
    Port ( input1 : in std_logic_vector (expWidth+fracWidth downto 0);
         input2 : in std_logic_vector (expWidth+fracWidth downto 0);
         addSub : in std_logic;
         sum : out std_logic_vector (expWidth+fracWidth downto 0));
end FloP_AddSub_Generic_top;

architecture Behavioral of FloP_AddSub_Generic_top is
    
    component FloP_AddSub_Generic is
        Generic ( expWidth : integer := 11; fracWidth : integer := 52 );
        Port ( input1 : in std_logic_vector (expWidth+fracWidth downto 0);
               input2 : in std_logic_vector (expWidth+fracWidth downto 0);
               addSub : in std_logic;
               sum : out std_logic_vector (expWidth+fracWidth downto 0));
    end component;
    
    component Mux_Generic is
        Generic ( dataWidth : integer );
        Port ( dataIn1 : in std_logic_vector (dataWidth-1 downto 0);
               dataIn2 : in std_logic_vector (dataWidth-1 downto 0);
               selectIn : in std_logic;
               dataOut : out std_logic_vector (dataWidth-1 downto 0));
    end component;
    
    constant dataWidth : integer := expWidth + fracWidth + 1;
    
    signal orderSelect, op, signSelect : std_logic; 
    signal num1, num2 : std_logic_vector(dataWidth-2 downto 0);
    signal mySum : std_logic_vector(dataWidth-1 downto 0);
    signal mySign : std_logic_vector(0 downto 0);
begin

    signSelect <= input1(dataWidth-1) and (addSub xor input2(dataWidth-1));
--    op <= (input1(63) and input2(63)) or (input1(63) and not(addSub)) or (not(input1(63)) and (addSub xor input2(63)));
    op <= (not(input1(dataWidth-1)) and (addSub xor input2(dataWidth-1))) or (input1(dataWidth-1) and (addSub xnor input2(dataWidth-1)));
    orderSelect <= input1(dataWidth-1) and not(addSub xor input2(dataWidth-1));
    
    Mux1 : Mux_Generic Generic Map(dataWidth => dataWidth-1)
                       Port Map(dataIn1 => input1(dataWidth-2 downto 0), dataIn2 => input2(dataWidth-2 downto 0), selectIn => orderSelect, 
                                dataOut => num1);
    Mux2 : Mux_Generic Generic Map(dataWidth => dataWidth-1)
                       Port Map(dataIn1 => input2(dataWidth-2 downto 0), dataIn2 => input1(dataWidth-2 downto 0), selectIn => orderSelect,
                                dataOut => num2);                            
    myAdder : FloP_AddSub_Generic Generic Map(expWidth => expWidth, fracWidth => fracWidth) 
                       Port Map(input1 => '0' & num1, input2 => '0' & num2, addSub => op, sum => mySum);
    Mux3 : Mux_Generic Generic Map(dataWidth => 1)
                       Port Map(dataIn1 => mySum(dataWidth-1 downto dataWidth-1), dataIn2 => not(mySum(dataWidth-1 downto dataWidth-1)), 
                                selectIn => signSelect, dataOut => mySign);

    sum <= mySign & mySum(dataWidth-2 downto 0);
end Behavioral;
