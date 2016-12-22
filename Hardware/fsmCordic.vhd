-- Finite State Machine for exteded hyperbolic cordic, Kazumi Malhan, Final Project

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;

entity fsmCoridc is
    generic (N: INTEGER:= 32);
    port (clock, resetn, s, vNeg, vPos: in std_logic;      
            sNeg, sPos, done: out std_logic);
end fsmCoridc;

architecture Behavioral of fsmCoridc is

    type state is (S1, S2, S3, S4);
    signal st: state;
    
begin
    
    Transitions: process (resetn, clock, s, vNeg, vPos)
    begin
        if resetn = '0' then
            st <= S1;
        elsif (clock'event and clock = '1') then
            case st is
                when S1 =>
                    if s = '1' then st <= S2; else st <= S1; end if;
                when S2 =>
                    if vNeg = '1' then st <= S3; else st <= S2; end if;
                when S3 =>
                    if vPos = '1' then st <= S4; else st <= S3; end if;
                when S4 =>
                    if s = '0' then st <= S1; else st <= S4; end if;
            end case;
        end if;
     end process;
     
     Outputs: process (st, s, s, vNeg, vPos)
     begin
     -- Initialize output
        sNeg <= '0'; sPos <= '0'; done <= '0';
     
        case st is 
            when S1 =>
                if s = '1' then sNeg <= '1'; end if;
            when S2 =>
                if vNeg = '1' then sPos <= '1'; end if;
            when S3 => sNeg <= '0';            
            when S4 =>
                done <= '1';
        end case;
    end process;
    
end Behavioral;