-- Test Bench for top_levelPower, Kazumi Malhan, Final Project
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
 
ENTITY tb_top_levelPower IS
END tb_top_levelPower;
 
ARCHITECTURE behavior OF tb_top_levelPower IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
--#########################################################################
-- Note that GENERIC number need to be changed depends on float or double
--#########################################################################
    COMPONENT top_levelPower
    GENERIC (N: INTEGER:= 64;
             EXP: INTEGER:= 11;
             FR: INTEGER:= 52);
    PORT (clock, resetn, s: IN std_logic;
            X, Y: IN std_logic_vector(EXP+FR downto 0);
            power: OUT std_logic_vector(EXP+FR downto 0);
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
   signal X : std_logic_vector(N-1 downto 0);
   signal Y : std_logic_vector(N-1 downto 0);
   
 	--Outputs
   signal power : std_logic_vector(N-1 downto 0);
   signal done : std_logic := '0';

   -- Clock period definitions
   constant T: time := 20 ns;
 	constant DUTY_CYCLE: real:= 0.5;
	constant OFFSET: time:= 20 ns;
	
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: top_levelPower PORT MAP (
          clock => clock,
          resetn => resetn,
          s => s,
          X => X,
          Y => Y,
          power => power,
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
   begin		
      -- hold reset state for 100 ns.
      wait for OFFSET;	

      resetn <= '0'; wait for T*1;
      -- insert stimulus here 
	   resetn <= '1'; wait for T*1;
        
--        --##################### N = 32 bit Test Cases ##############################################
--        -- Test Case 1
--        -- X = 10,  Y = 2  Target = power = 10^2
--        s <= '1'; X <= x"41200000"; Y <= x"40000000"; wait for T*70; 
--        s <= '0'; wait for T*2;
        
--        -- Test Case 2
--        -- X = 2,  Y = 10  Target = power = 2^10
--        s <= '1'; X <= x"40000000"; Y <= x"41200000"; wait for T*70; 
--        s <= '0'; wait for T*2; 
        
        --##################### N = 64 bit Test Cases ##############################################
        -- Test Case 1
        -- X = 10,  Y = 2  Target = power = 10^2
        s <= '1'; X <= x"4024000000000000"; Y <= x"4000000000000000"; wait for T*70; 
        s <= '0'; wait for T*2;
        
        -- Test Case 2
        -- X = 2,  Y = 10  Target = power = 2^10
        s <= '1'; X <= x"4000000000000000"; Y <= x"4024000000000000"; wait for T*70; 
        s <= '0'; wait for T*2; 
		
      wait;
   end process;

END;
