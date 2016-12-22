-- Top Level inside FIFO, Kazumi Malhan, Final Project
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;

entity top_levelFIFO is
    generic (N: INTEGER:= 32;
             EXP: INTEGER:= 8;
             FR: INTEGER:= 23);
	port (clock, resetn: in std_logic;
	      DI: in std_logic_vector (31 downto 0);
	      DO: out std_logic_vector (31 downto 0);
	      iempty, ofull: in std_logic;
          irden, owren: out std_logic);
end top_levelFIFO;

architecture structure of top_levelFIFO is
    
    component my_rege
       generic (N: INTEGER:= 32);
        port ( clock, resetn: in std_logic;
               E : in std_logic; -- sclr: Synchronous clear
                 D: in std_logic_vector (N-1 downto 0);
               Q: out std_logic_vector (N-1 downto 0));
    end component;

    component busMux
        generic (N: INTEGER:= 32); -- Length of each input signal
	   port (a,b: in std_logic_vector (N-1 downto 0);
	      s: in std_logic;
	      y: out std_logic_vector (N-1 downto 0));
    end component;
    
    component top_levelPower
        generic (N: INTEGER:= 32;
                 EXP: INTEGER:= 8;
                 FR: INTEGER:= 23);
        port (clock, resetn, s: in std_logic;
              X, Y: in std_logic_vector (EXP+FR downto 0);
              power: out std_logic_vector (EXP+FR downto 0);
              done: out std_logic);
    end component;
    
    component inFIFOfsm32
        port (clock, resetn: in std_logic;
              v, iempty, ofull: in std_logic;
              E, Eri, Er, irden: out std_logic);
    end component;
    
    component outFIFOfsm32
        port (clock, resetn: in std_logic;
              v: in std_logic;
              E_buf, owren: out std_logic);
    end component;
    
    component inFIFOfsm64
        port (clock, resetn: in std_logic;
              v, iempty, ofull: in std_logic;
              E, Ex1, Ex2, Ey1, Ey2, irden: out std_logic);
    end component;
    
    component outFIFOfsm64
        port (clock, resetn: in std_logic;
              v: in std_logic;
              E_buf, owren, sy: out std_logic);
    end component;
    
    -- NEED TO ADD FSM compinents
    
    signal DIX, DIY, POW, DOP: std_logic_vector(N-1 downto 0);
    signal Eri, Er, E_buf, Ey, Vy: std_logic;
    signal Ex1, Ex2, Ey1, Ey2, sy: std_logic;
  
begin
-- Depending on FP format, create different digital circuit
--------------------------------------------------------------------------------------------------
bit64: if (N = 64) generate
-- Register => put input to X1
reg1: my_rege generic map(N => 32)
               port map (clock => clock, resetn => resetn, E => Ex1, D => DI, Q => DIX(63 downto 32)); 
-- Register => put input to X2
reg2: my_rege generic map(N => 32)
                port map (clock => clock, resetn => resetn, E => Ex2, D => DI, Q => DIX(31 downto 0)); 
-- Register => put input to Y1
reg3: my_rege generic map(N => 32)
                port map (clock => clock, resetn => resetn, E => Ey1, D => DI, Q => DIY(63 downto 32));
-- Register => put input to Y2
reg4: my_rege generic map(N => 32)
                port map (clock => clock, resetn => resetn, E => Ey2, D => DI, Q => DIY(31 downto 0));
-- Register => Save final output          
reg5: my_rege generic map(N => 64)
            port map (clock => clock, resetn => resetn, E => E_buf, D => POW, Q => DOP);                                                         
-- Mux for output
mux1: busMux generic map(N => 32)
               port map (a => DOP(63 downto 32), b => DOP(31 downto 0), s => sy, y => DO);
-- inFIFO
infsm: inFIFOfsm64 port map (clock => clock, resetn => resetn, v => Vy, iempty => iempty, ofull => ofull,
                             E => Ey, Ex1 => Ex1, Ex2 => Ex2, Ey1 => Ey1, Ey2 => Ey2, irden => irden);
-- outFIFO             
outfsm: outFIFOfsm64 port map (clock => clock, resetn => resetn, v => Vy, E_buf => E_buf, owren => owren, sy => sy);

    end generate;               
---------------------------------------------------------------------------------------------------
bit32: if (N = 32) generate
-- Register => put input to X
reg1: my_rege generic map(N => 32)
               port map (clock => clock, resetn => resetn, E => Eri, D => DI, Q => DIX);
-- Register => put input to Y
reg2: my_rege generic map(N => 32)
              port map (clock => clock, resetn => resetn, E => Er, D => DI, Q => DIY);
-- Register => save final output
reg3: my_rege generic map(N => 32)
              port map (clock => clock, resetn => resetn, E => E_buf, D => POW, Q => DO);               
-- inFIFO
infsm: inFIFOfsm32 port map (clock => clock, resetn => resetn, v => Vy, iempty => iempty,
                             ofull => ofull, E => Ey, Eri => Eri, Er => Er, irden => irden);
-- outFIFO 
outfsm: outFIFOfsm32 port map (clock => clock, resetn => resetn, v => Vy, E_buf => E_buf, owren => owren);

    end generate;
---------------------------------------------------------------------------------------------------
-- FP Power => Core of calculation
power1: top_levelPower generic map (N => N, EXP => EXP, FR => FR)
                        port map (clock => clock, resetn => resetn, s => Ey, X => DIX, Y => DIY,
                                  power => POW, done => Vy);
---------------------------------------------------------------------------------------------------------------------

end structure;