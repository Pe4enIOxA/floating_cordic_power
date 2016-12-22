-- Negative Finite State Machine, Kazumi Malhan, Final Project

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;

entity fsmNeg is
    generic(N: INTEGER:= 31);
    port (clock, resetn, s, mode: in std_logic;
            X, Y, Z: in std_logic_vector(N-1 downto 0);           
            i: out std_logic_vector(2 downto 0);
            E, di, s_xyz, done: out std_logic);
end fsmNeg;

architecture Behavioral of fsmNeg is

    component my_countNeg
        	port ( clock, resetn, E, sclr: in std_logic;
             Q: out integer;
             z: out std_logic);
    end component;

    type state is (S1, S2, S3, S4);
    signal st: state;
    signal Ec, zy, sclr: std_logic;
    signal it: integer range 0 to 5;
    
begin

ct1: my_countNEg port map (clock => clock, resetn => resetn, E => Ec, Q => it, z => zy, sclr => sclr);
    
    Transitions: process (resetn, clock, s, Y, Z, X, mode, zy)
    begin
        if resetn = '0' then
            st <= S1;
        elsif (clock'event and clock = '1') then
            case st is
                when S1 =>
                    if s = '1' then
                        if mode = '0' then st <= S2; else st <= S3; end if;
                    else st <= S1; end if;
                when S2 =>
                    if zy = '1' then st <= S4; else st <= S2; end if;
                when S3 =>
                    if zy = '1' then st <= S4; else st <= S3; end if;
                when S4 =>
                    if s = '0' then st <= S1; else st <= S4; end if;
            end case;
        end if;
     end process;
     
     Outputs: process (st, s, mode, Z, Y, X, it)
     begin
     -- Initialize output
        E <= '0'; di <= '0'; s_xyz <= '0'; done <= '0'; Ec <= '0'; sclr <= '0';
     
        case st is 
            when S1 =>
                if s = '1' then s_xyz <= '1'; E <= '1'; Ec <= '1'; sclr <= '1'; end if;
            when S2 =>
                E <= '1'; Ec <= '1';
                if Z(N-1) = '1' then di <= '1'; else di <= '0'; end if;
            when S3 =>
                E <= '1'; Ec <= '1';
                if X(N-1) = Y(N-1) then di <= '1'; else di <= '0'; end if;           
            when S4 =>
                done <= '1';
        end case;
    end process;
    i <= conv_std_logic_vector(it+2,3);
    
end Behavioral;