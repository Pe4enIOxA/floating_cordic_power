-- Finite State Machine for output FIFO (single), Kazumi Malhan, Final Project

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;
use ieee.std_logic_unsigned.all;

entity outFIFOfsm32 is
    port (clock, resetn: in std_logic;
          v: in std_logic;
          E_buf, owren: out std_logic);
end outFIFOfsm32;

architecture Behavioral of outFIFOfsm32 is

    type state is (S1, S2, S3);
    signal su: state;
    
begin
    
    Transitions: process (resetn, clock, v)
    begin
        if resetn = '0' then
            su <= S1;
        elsif (clock'event and clock = '1') then
            case su is
                when S1 =>
                    if v = '0' then su <= S2; else su <= S1; end if;
                when S2 =>
                    if v = '1' then su <= S3; else su <= S2; end if;
                when S3 => su <= S1;
            end case;
        end if;
     end process;
     
     Outputs: process (su, v)
     begin
     -- Initialize output
        E_buf <= '0'; owren <= '0';
     
        case su is 
            when S1 => E_buf <= '0';
            when S2 =>
                if v = '1' then E_buf <= '1'; end if;
            when S3 => owren <= '1';         
        end case;
    end process;
    
end Behavioral;