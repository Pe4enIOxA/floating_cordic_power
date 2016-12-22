-- Power Operation Top Level, Kazumi Malhan, Final Project
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;

entity top_levelPower is
    generic (N: INTEGER:= 32;
             EXP: INTEGER:= 8;
             FR: INTEGER:= 23);
	port (clock, resetn, s: in std_logic;
	      X, Y: in std_logic_vector (EXP+FR downto 0);
	      power: out std_logic_vector (EXP+FR downto 0);
	      done: out std_logic);
end top_levelPower;

architecture structure of top_levelPower is
	
    component fsmPower
        port (clock, resetn, s, vCordic: in std_logic;
                Vaddsub, Ey, s_xyz, mode, Eout, sCordic, done: out std_logic);
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
    
    component top_levelCordic
        generic (N: INTEGER:= 32;
                 EXP: INTEGER:= 8;
                 FR: INTEGER:= 23);
        port (clock, resetn, s, mode: in std_logic;
              Xin, Yin, Zin: in std_logic_vector (N-1 downto 0);
              Xout, Yout, Zout: out std_logic_vector (N-1 downto 0);
              done: out std_logic);
    end component;
    
    component FloP_Multiplier
        Generic ( expWidth : integer := 11; fracWidth : integer := 52 );
        Port ( num1, num2 : in std_logic_vector(expWidth+fracWidth downto 0);
               clk : in std_logic;
               product : out std_logic_vector(expWidth+fracWidth downto 0));
    end component;

    signal one, Vxy, RotX, Vy, Vz, ylnx: std_logic_vector(N-1 downto 0);
    signal Xin, Yin, Zin, Xout, Yout, Zout: std_logic_vector(N-1 downto 0);    
    signal s_xyz, Vaddsub, Ey, sCordic, vCordic, Eout, modey: std_logic;
    
begin

-- Generate Constants --------------------
bit64: if (N = 64) generate
    RotX <= x"409f03697b5d5cd4";
    one <= x"3ff0000000000000";
end generate;

bit32: if N = 32 generate
    RotX <= x"44F81B4C";
    one <= x"3F800000";
end generate;

bit24: if N = 24 generate
    RotX <= "010010010111100000011011";
    one <= "001111101000000000000000";
end generate;

bit16: if N = 16 generate
    RotX <= "0101001011110000";
    one <= "0011110100000000";
end generate;
------------------------------------------------------------------------------------
-- Full Add/Sub => Creating input for vector mode
full1: FloP_AddSub_Generic_top generic map(expWidth => EXP, fracWidth => FR)
                                port map (addSub => Vaddsub, input1 => X, input2 => one, sum => Vxy);
--------------------------------------------------------------------------------------------------
-- Register => put input to Y
reg1: my_rege generic map(N => N)
               port map (clock => clock, resetn => resetn, E => Ey, D => Vxy, Q => Vy); 
------------------------------------------------------------------------------------------------                              
-- Mux for X
mux1: busMux generic map(N => N)
               port map (a => Vxy, b => RotX, s => s_xyz, y => Xin);              
-- Mux for Y               
mux2: busMux generic map(N => N)
              port map (a => Vy, b => RotX, s => s_xyz, y => Yin);
-- Mux for Z                              
mux3: busMux generic map(N => N)
              port map (a => (others => '0'), b => ylnx, s => s_xyz, y => Zin);
---------------------------------------------------------------------------------------------------
-- FP Extended Hyperbolic Cordic => Core of calculation
cordic1: top_levelCordic generic map (N => N, EXP => EXP, FR => FR)
                        port map (clock => clock, resetn => resetn, s => sCordic, mode => modey, Xin => Xin, Yin => Yin, Zin => Zin,
                                  Xout => Xout, Yout => Yout, Zout => Zout, done => vCordic);
--------------------------------------------------------------------------------------                          
-- Barrel shifter => Multiply the vector result by 2               
bs1: FloP_Shifter_Generic generic map (expWidth => EXP, fracWidth => FR)
                            port map (inputData => Zout, shiftAmt(0) => '1', shiftAmt(EXP-1 downto 1) => (others => '0'), leftRight => '0', outputData => Vz);           
---------------------------------------------------------------------------------------------------------------
-- Multiplier => Multiply the vector result with y
mult1: FloP_Multiplier generic map (expWidth => EXP, fracWidth => FR)
                        port map (num1 => Y, num2 => Vz, clk => clock, product => ylnx);
---------------------------------------------------------------------------------------------------------------------
-- Register => Save final output          
reg2: my_rege generic map(N => N)
              port map (clock => clock, resetn => resetn, E => Eout, D => Xout, Q => power); 
---------------------------------------------------------------------------------------------- 
-- Finite State Machine => Control power           
fsm1: fsmPower port map (clock => clock, resetn => resetn, s => s, vCordic => vCordic, 
                        Vaddsub => Vaddsub, Ey => Ey, s_xyz => s_xyz, mode => modey, Eout => Eout, sCordic => sCordic, done => done);   
------------------------------------------------------------------------------------------------------------------

end structure;