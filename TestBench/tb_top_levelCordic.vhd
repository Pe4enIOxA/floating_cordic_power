-- Test Bench for FP Extended Hyperbolic cordic, Kazumi Malhan, Final Project
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

use std.textio.all;
use ieee.std_logic_textio.all;
 
ENTITY tb_top_levelCordic IS
END tb_top_levelCordic;
 
ARCHITECTURE behavior OF tb_top_levelCordic IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
    --#########################################################################
    -- Note that GENERIC number need to be changed depends on float or double
    --#########################################################################
    COMPONENT top_levelCordic
    GENERIC (N: INTEGER:= 64;
             EXP: INTEGER:= 11;
             FR: INTEGER:= 52);
    PORT (clock, resetn, s, mode: IN std_logic;
            Xin, Yin, Zin: IN std_logic_vector(N-1 downto 0);
            Xout, Yout, Zout: OUT std_logic_vector(N-1 downto 0);
            done: OUT std_logic);
    END COMPONENT;
--    --################# When N = 32 ##################
--    constant N: INTEGER := 32;
--    constant EXP: INTEGER := 8;
--    constant FR: INTEGER := 23;
    
    --################# When N = 64 ##################
    constant N: INTEGER := 64;
    constant EXP: INTEGER := 11;
    constant FR: INTEGER := 52;

   --Inputs
   signal clock : std_logic := '0';
   signal resetn : std_logic := '0';
   signal s : std_logic := '0';
   signal mode : std_logic := '0';
   signal Xin : std_logic_vector(N-1 downto 0);
   signal Yin : std_logic_vector(N-1 downto 0);
   signal Zin : std_logic_vector(N-1 downto 0);
   
 	--Outputs
   signal Xout : std_logic_vector(N-1 downto 0);
   signal Yout : std_logic_vector(N-1 downto 0);
   signal Zout : std_logic_vector(N-1 downto 0);
   signal done : std_logic := '0';
   
   --constant in_bench: STRING:="in_bench_ex.txt";
    constant in_bench: STRING:="in_bench_ln.txt";
    
   -- Clock period definitions
   constant T: time := 20 ns;
 	constant DUTY_CYCLE: real:= 0.5;
	constant OFFSET: time:= 20 ns;
	
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: top_levelCordic PORT MAP (
          clock => clock,
          resetn => resetn,
          s => s,
          mode => mode,
          Xin => Xin,
          Yin => Yin,
          Zin => Zin,
          Xout => Xout,
          Yout => Yout,
          Zout => Zout,
          done => done
        );

   -- Clock process definitions
   clock_process :process
   begin
			clock <= '0'; 
			wait for 10 ns;
			clock <= '1'; 
			wait for 10 ns;
   end process; 

   -- Stimulus process
   stim_proc: process
      file IN_FILE: TEXT open READ_MODE is in_bench;
   variable BUFI: line;
   variable VAR: std_logic_vector(63 downto 0);  
   
   begin		
      -- hold reset state for 100 ns.
      wait for OFFSET;	

      resetn <= '0'; wait for T*1;
      -- insert stimulus here 
	   resetn <= '1'; wait for T*1;
	   
--	   	   -- Test ex
--        mode <= '0'; Xin <= x"409f03697b5d5cd4"; Yin <= x"409f03697b5d5cd4";
       
--        l_tb: for j in 0 to 248 loop
--            exit l_tb when endfile(IN_FILE);
--            readline (IN_FILE, BUFI);
--            hread (BUFI, var);
--                s <= '1';
--                Zin <= var;
--            wait for T*26;
--            s <= '0'; wait for T;
--            end loop;
            
            	   	   -- Test ln(y)
      mode <= '1'; Zin <= x"0000000000000000";
     
      l_tb: for j in 0 to 821 loop
          exit l_tb when endfile(IN_FILE);
          readline (IN_FILE, BUFI);
          hread (BUFI, var);
              s <= '1';
              Xin <= var;
          readline (IN_FILE, BUFI);
          hread (BUFI, var);
              Yin <= var;
          wait for T*26;
          s <= '0'; wait for T;
          end loop;
         
--        --##################### N = 32 bit Test Cases ##############################################
--        -- Rotation Mode
--        -- X = Y = 1/An,  Z = 2  Target = Xn = Yn = e^2
--        s <= '1'; mode <= '0'; Xin <= x"44F81CCD"; Yin <= x"44F81CCD"; Zin <= x"40000000"; wait for T*30; 
--        s <= '0'; wait for T*2;
        
--        -- Vector Mode
--        -- X = 10+1, Y = 10-1, Z = 0 Target Zn = ln(10)/2
--        s <= '1'; mode <= '1'; Xin <= x"41300000"; Yin <= x"41100000"; Zin <= x"00000000"; wait for T*30;
--        s <= '0'; wait for T*2;
        
        --################### N = 64 bit Test Cases ##################################################
--        -- Rotation Mode
--        -- X = Y = 1/An,  Z = 2  Target = Xn = Yn = e^2
--        s <= '1'; mode <= '0'; Xin <= x"409f03697b5d5cd4"; Yin <= x"409f03697b5d5cd4"; Zin <= x"4000000000000000"; wait for T*30; 
--        s <= '0'; wait for T*2;
        
--        -- Vector Mode
--        -- X = 10+1, Y = 10-1, Z = 0 Target Zn = ln(10)/2
--        s <= '1'; mode <= '1'; Xin <= x"4026000000000000"; Yin <= x"4022000000000000"; Zin <= x"0000000000000000"; wait for T*30;
--        s <= '0'; wait for T*2;	
		
      wait;
   end process;
   
   	tb_o: process
               --file OUT_FILE: TEXT open WRITE_MODE is "out_bench_ex.txt";
               file OUT_FILE: TEXT open WRITE_MODE is "out_bench_ln.txt";
               variable BUFO: line;
               variable OVX: std_logic_vector (63 downto 0);
   
             begin
                       wait until done = '1' and (clock'event and clock='1');
                       --OVX:= Xout;
                       OVX:= Zout;
                       hwrite(BUFO, OVX); --use hwrite if you know it's gonna work!
                       writeline(OUT_FILE, BUFO);                             
                       wait for T;         
             end process;

END;
