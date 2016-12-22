-- Power Operation Finite State Machine, Kazumi Malhan, Final Project

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;

entity fsmPower is
    port (clock, resetn, s, vCordic: in std_logic;
            Vaddsub, Ey, s_xyz, mode, Eout, sCordic, done: out std_logic);
end fsmPower;

architecture Behavioral of fsmPower is

    type state is (S1, S2, S3, S4, S5, S6, S7);
    signal st: state;
    --signal Ec, zy, sclr: std_logic;
    
begin
   
    Transitions: process (resetn, clock, s, vCordic)
    begin
        if resetn = '0' then
            st <= S1;
        elsif (clock'event and clock = '1') then
            case st is
                when S1 =>
                    if s = '1' then st <= S2; else st <= S1; end if;
                when S2 => st <= S3;
                when S3 =>
                    if vCordic = '1' then st <= S4; else st <= S3; end if;
                when S4 => st <= S5;
                when S5 => st <= S6;
                when S6 =>
                    if vCordic = '1' then st <= S7; else st <= S6; end if;
                when S7 =>
                    if s = '0' then st <= S1; else st <= S7; end if;
            end case;
        end if;
     end process;
     
     Outputs: process (st, s, vCordic)
     begin
     -- Initialize output
        Vaddsub <= '0'; Ey <= '0'; Eout <= '0'; s_xyz <= '0'; done <= '0'; sCordic <= '0'; mode <= '0';
     
        case st is 
            when S1 =>
                if s = '1' then Vaddsub <= '1'; Ey <= '1'; end if;
            when S2 =>
                Vaddsub <= '0'; s_xyz <= '0'; sCordic <= '1'; mode <= '1';
            when S3 =>
                mode <= '1';
                if vCordic = '1' then s_xyz <= '1'; end if;           
            when S4 =>
                s_xyz <= '1';
            when S5 =>
                s_xyz <= '1'; sCordic <= '1'; mode <= '0';
            when S6 =>
                mode <= '0';
                if vCordic = '1' then Eout <= '1'; end if;
            when S7 =>
                done <= '1';
        end case;
    end process;
    
end Behavioral;