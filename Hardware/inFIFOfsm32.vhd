-- Finite State Machine for FIFO input (single), Kazumi Malhan, Final Project

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;
use ieee.std_logic_unsigned.all;

entity inFIFOfsm32 is
    port (clock, resetn: in std_logic;
          v, iempty, ofull: in std_logic;
          E, Eri, Er, irden: out std_logic);
end inFIFOfsm32;

architecture Behavioral of inFIFOfsm32 is

    type state is (S1, S2, S3, S4, S5);
    signal sq: state;
    
begin
    
    Transitions: process (resetn, clock, v, iempty, ofull)
    begin
        if resetn = '0' then
            sq <= S1;
        elsif (clock'event and clock = '1') then
            case sq is
                when S1 =>
                    if iempty = '1' then sq <= S2; else sq <= S1; end if;
                when S2 =>
                    if (ofull = '0' and iempty = '0') then sq <= S3; else sq <= S2; end if;
                when S3 =>
                    if (ofull = '0' and iempty = '0') then sq <= S4; else sq <= S3; end if;
                when S4 => sq <= S5;
                when S5 =>
                    if v = '1' then sq <= S2; else sq <= S5; end if;
            end case;
        end if;
     end process;
     
     Outputs: process (sq, iempty, ofull)
     begin
     -- Initialize output
        E <= '0'; Eri <= '0'; irden <= '0'; Er <= '0';
     
        case sq is 
            when S1 => Eri <= '0';
            when S2 =>
                if (ofull = '0' and iempty = '0') then irden <= '1'; Eri <= '1'; end if;
            when S3 => 
                if (ofull = '0' and iempty = '0') then irden <= '1'; Er <= '1'; end if;
            when S4 => E <= '1';
            when S5 => E <= '0';               
        end case;
    end process;
    
end Behavioral;