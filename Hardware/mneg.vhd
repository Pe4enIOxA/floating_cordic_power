-- Negative Iteration Cordic, Kazumi Malhan, Final Project
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;

entity mneg is
    generic (N: INTEGER:= 32;
             EXP: INTEGER:= 7;
             FR: INTEGER:= 16);
	port (clock, resetn, s, mode: in std_logic;
	      Xin, Yin, Zin: in std_logic_vector (EXP+FR downto 0);
	      Xout, Yout, Zout: out std_logic_vector (EXP+FR downto 0);
	      done: out std_logic);
end mneg;

architecture structure of mneg is
	
	component fsmNeg
	generic (N: INTEGER:= 32);
        port (clock, resetn, s, mode: in std_logic;
                X, Y, Z: in std_logic_vector(N-1 downto 0);  
                i: out std_logic_vector(2 downto 0);
                E, di, s_xyz, done: out std_logic);
    end component;
    
    component my_negLUT
       generic (N: INTEGER:= 16);
        port (s: in std_logic_vector (2 downto 0);
              y: out std_logic_vector (N-1 downto 0));
    end component;
    
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
    
    component FloP_AddSub_Generic_top
        Generic ( expWidth : integer := 11; fracWidth : integer := 52 );
        Port ( input1 : in std_logic_vector (expWidth+fracWidth downto 0);
             input2 : in std_logic_vector (expWidth+fracWidth downto 0);
             addSub : in std_logic;
             sum : out std_logic_vector (expWidth+fracWidth downto 0));
    end component;
    
    component FloP_Shifter_Generic
        Generic ( expWidth, fracWidth : integer );
        Port ( inputData : in STD_LOGIC_VECTOR ((expWidth+fracWidth) downto 0); 
               shiftAmt : in STD_LOGIC_VECTOR (expWidth-1 downto 0);
               leftRight : in STD_LOGIC;
               outputData : out STD_LOGIC_VECTOR ((expWidth+fracWidth) downto 0) );
    end component;

    signal data_x, data_y, xt, yt, Xs, Ys, xu, yu: std_logic_vector(N-1 downto 0);
    signal next_x, next_y: std_logic_vector(N-1 downto 0);
    signal s_xyz, E, di, diz: std_logic;
    signal e_i, data_z, zt, next_z: std_logic_vector(N-1 downto 0);
    signal i: std_logic_vector(2 downto 0);
    
begin

------------------------------------------------------------------------------------
-- Mux for X
mux1: busMux generic map(N => N)
               port map (a => next_x, b => Xin, s => s_xyz, y => data_x);              
-- Mux for Y               
mux2: busMux generic map(N => N)
              port map (a => next_y, b => Yin, s => s_xyz, y => data_y);
-- Mux for Z                              
mux3: busMux generic map(N => N)
              port map (a => next_z, b => Zin, s => s_xyz, y => data_z);           
--------------------------------------------------------------------------------------              
-- Register for X (Neg_xReg)              
reg1: my_rege generic map(N => N)
              port map (clock => clock, resetn => resetn, E => E, D => data_x, Q => xt); 
-- Register for Y (Neg_yReg)
reg2: my_rege generic map(N => N)
               port map (clock => clock, resetn => resetn, E => E, D => data_y, Q => yt); 
-- Register for Z (Neg_zReg)                              
reg3: my_rege generic map(N => N)
               port map (clock => clock, resetn => resetn, E => E, D => data_z, Q => zt);
---------------------------------------------------------------------------------------------
-- Not version of add/sub selection signal               
diz <= not(di);
----------------------------------------------------------------------------------------------             
-- addsub for X (Before shift)
full1: FloP_AddSub_Generic_top generic map(expWidth => EXP, fracWidth => FR)
                                port map (addSub => di, input1 => xt, input2 => yt, sum => xu);
-- addsub for Y  (Before shift)               
full2: FloP_AddSub_Generic_top generic map(expWidth => EXP, fracWidth => FR)
                                port map (addSub => di, input1 => yt, input2 => xt, sum => yu);                               
--------------------------------------------------------------------------------------------------------------
-- Barrel shifter for X               
bs1: FloP_Shifter_Generic generic map (expWidth => EXP, fracWidth => FR)
                            port map (inputData => xt, shiftAmt(2 downto 0) => i, shiftAmt(EXP-1 downto 3) => (others => '0'), leftRight => '1', outputData => Xs);                                                     
-- Barrel shifter for Y
bs2: FloP_Shifter_Generic generic map (expWidth => EXP, fracWidth => FR)
                            port map(inputData => yt, shiftAmt(2 downto 0) => i, shiftAmt(EXP-1 downto 3) => (others => '0'), leftRight => '1', outputData => Ys); 
---------------------------------------------------------------------------------------------------------------
-- LUT using BusMux
lut1: my_negLUT generic map (N => N)
                    port map(s => i, y => e_i);                 
---------------------------------------------------------------------------------------------------------------
-- addsub for X
full3: FloP_AddSub_Generic_top generic map(expWidth => EXP, fracWidth => FR)
                                port map (addSub => diz, input1 => xu, input2 => Ys, sum => next_x);
-- addsub for Y                
full4: FloP_AddSub_Generic_top generic map(expWidth => EXP, fracWidth => FR)
                                port map (addSub => diz, input1 => yu, input2 => Xs, sum => next_y);
-- addsub for Z                         
full5: FloP_AddSub_Generic_top generic map(expWidth => EXP, fracWidth => FR)
                                port map (addSub => diz, input1 => zt, input2 => e_i, sum => next_z);
---------------------------------------------------------------------------------------------------------------------
-- Finite State Machine                  
fsm1: fsmNeg    generic map(N => N)
                 port map (clock => clock, resetn => resetn, s => s, mode => mode, X => xt, Y => yt, Z => zt, di => di, s_xyz => s_xyz, E => E, i => i, done => done);        
------------------------------------------------------------------------------------------------------------------
Xout <= xt;
Yout <= yt;
Zout <= zt;

end structure;