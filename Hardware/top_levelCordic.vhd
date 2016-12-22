-- Top Level for Extended Hyperbolic Cordic, Kazumi Malhan, Final Project
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;

entity top_levelCordic is
    generic (N: INTEGER:= 32;
             EXP: INTEGER:= 8;
             FR: INTEGER:= 23);
	port (clock, resetn, s, mode: in std_logic;
	      Xin, Yin, Zin: in std_logic_vector (N-1 downto 0);
	      Xout, Yout, Zout: out std_logic_vector (N-1 downto 0);
	      done: out std_logic);
end top_levelCordic;

architecture structure of top_levelCordic is
	
    component fsmCoridc
        generic (N: INTEGER:= 32);
        port (clock, resetn, s, vNeg, vPos: in std_logic;      
                sNeg, sPos, done: out std_logic);
    end component;
    
    component mneg
        generic (N: INTEGER:= 32;
                 EXP: INTEGER:= 7;
                 FR: INTEGER:= 16);
        port (clock, resetn, s, mode: in std_logic;
              Xin, Yin, Zin: in std_logic_vector (N-1 downto 0);
              Xout, Yout, Zout: out std_logic_vector (N-1 downto 0);
              done: out std_logic);
    end component;
    
    component npos
        generic (N: INTEGER:= 32;
                 EXP: INTEGER:= 7;
                 FR: INTEGER:= 16);
        port (clock, resetn, s, mode: in std_logic;
              Xin, Yin, Zin: in std_logic_vector (N-1 downto 0);
              Xout, Yout, Zout: out std_logic_vector (N-1 downto 0);
              done: out std_logic);
    end component;
    
    signal Xn, Yn, Zn, Xb, Yb, Zb, Xo, Yo, Zo: std_logic_vector(N-1 downto 0);
    signal s_xyz, E, di, diz: std_logic;
    signal i: std_logic_vector(3 downto 0);
    signal sNegy, sPosy, vNegy, vPosy: std_logic;
    
begin
Xn <= Xin;
Yn <= Yin;
Zn <= Zin;

Neg: mneg generic map (N => N, EXP => EXP, FR => FR)
            port map (clock => clock, resetn => resetn, s => sNegy, mode => mode, Xin => Xn, Yin => Yn, Zin => Zn, Xout => Xb, Yout => Yb, Zout => Zb, done => vNegy);
            
Pos: npos generic map (N => N, EXP => EXP, FR => FR)
                        port map (clock => clock, resetn => resetn, s => sPosy, mode => mode, Xin => Xb, Yin => Yb, Zin => Zb, Xout => Xo, Yout => Yo, Zout => Zo, done => vPosy);

-- Finite State Machine                  
fsm1: fsmCoridc port map (clock => clock, resetn => resetn, s => s, sNeg => sNegy, sPos => sPosy, vNeg => vNegy, vPos => vPosy, done => done);     

Xout <= Xo;
Yout <= Yo;
Zout <= Zo;

end structure;