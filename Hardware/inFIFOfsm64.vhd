-- Finite State Machine for FIFO input (double), Kazumi Malhan, Final Project

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;
use ieee.std_logic_unsigned.all;

entity inFIFOfsm64 is
    port (clock, resetn: in std_logic;
          v, iempty, ofull: in std_logic;
          E, Ex1, Ex2, Ey1, Ey2, irden: out std_logic);
end inFIFOfsm64;

architecture Behavioral of inFIFOfsm64 is

    type state is (S1, S2, S3, S4, S5, S6, S7);
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
                when S4 =>
                    if (ofull = '0' and iempty = '0') then sq <= S5; else sq <= S4; end if;
                when S5 =>
                    if (ofull = '0' and iempty = '0') then sq <= S6; else sq <= S5; end if;
                when S6 => sq <= S7;
                when S7 =>
                    if v = '1' then sq <= S2; else sq <= S7; end if;
            end case;
        end if;
     end process;
     
     Outputs: process (sq, iempty, ofull)
     begin
     -- Initialize output
        E <= '0'; Ex1 <= '0'; Ex2 <= '0'; Ey1 <= '0'; Ey2 <= '0'; irden <= '0';
     
        case sq is 
            when S1 => Ex1 <= '0';
            when S2 =>
                if (ofull = '0' and iempty = '0') then irden <= '1'; Ex1 <= '1'; end if;
            when S3 =>
                if (ofull = '0' and iempty = '0') then irden <= '1'; Ex2 <= '1'; end if;
            when S4 =>
                if (ofull = '0' and iempty = '0') then irden <= '1'; Ey1 <= '1'; end if;
            when S5 => 
                if (ofull = '0' and iempty = '0') then irden <= '1'; Ey2 <= '1'; end if;
            when S6 => E <= '1';
            when S7 => E <= '0';               
        end case;
    end process;
    
end Behavioral;