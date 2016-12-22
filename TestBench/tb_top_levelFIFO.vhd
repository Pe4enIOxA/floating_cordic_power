-- Test Bench for top_levelFIFO, Kazumi Malhan, Final Project
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
 
ENTITY tb_top_levelFIFO IS
END tb_top_levelFIFO;
 
ARCHITECTURE behavior OF tb_top_levelFIFO IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
--#########################################################################
-- Note that GENERIC number need to be changed depends on float or double
--#########################################################################
    COMPONENT top_levelFIFO
    GENERIC (N: INTEGER:= 32;
             EXP: INTEGER:= 8;
             FR: INTEGER:= 23);
    PORT (clock, resetn: IN std_logic;
            DI: IN std_logic_vector(31 downto 0);
            DO: OUT std_logic_vector(31 downto 0);
            iempty, ofull: IN std_logic;
            irden, owren: OUT std_logic);
    END COMPONENT;
    
    --################# When N = 32 ##################
        constant N: INTEGER := 32;
        constant EXP: INTEGER := 8;
        constant FR: INTEGER := 23;
        
--        --################# When N = 64 ##################
--        constant N: INTEGER := 64;
--        constant EXP: INTEGER := 11;
--        constant FR: INTEGER := 52;
        
   --Inputs
   signal clock : std_logic := '0';
   signal resetn : std_logic := '0';
   signal iempty : std_logic := '0';
   signal ofull : std_logic := '0';
   signal DI : std_logic_vector(31 downto 0);
   
 	--Outputs
   signal DO : std_logic_vector(31 downto 0);
   signal irden : std_logic := '0';
   signal owren : std_logic := '0';
   
   -- Clock period definitions
   constant T: time := 20 ns;
 	constant DUTY_CYCLE: real:= 0.5;
	constant OFFSET: time:= 20 ns;
	
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: top_levelFIFO PORT MAP (
          clock => clock,
          resetn => resetn,
          iempty => iempty,
          ofull => ofull,
          DI => DI,
          DO => DO,
          irden => irden,
          owren => owren
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
	   resetn <= '1'; iempty <= '1'; ofull <= '0'; wait for T*2;
        
        --##################### N = 32 bit Test Cases ##############################################
        -- Test Case 1
        -- X = 10,  Y = 2  Target = power = 10^2
        iempty <= '0'; ofull <= '0'; DI <= x"41200000"; wait for T; -- X
        iempty <= '0'; ofull <= '0'; DI <= x"40000000"; wait for T; -- Y
        iempty <= '1'; ofull <= '0'; DI <= x"12345678"; wait for T*70; -- Dummy
        
        -- Test Case 2
        -- X = 2,  Y = 10  Target = power = 2^10
        iempty <= '0'; ofull <= '0'; DI <= x"40000000"; wait for T; -- X
        iempty <= '0'; ofull <= '0'; DI <= x"41200000"; wait for T; -- Y
        iempty <= '1'; ofull <= '0'; DI <= x"12345678"; wait for T*70; -- Dummy 
        
--        --##################### N = 64 bit Test Cases ##############################################
--        -- Test Case 1
--        -- X = 10,  Y = 2  Target = power = 10^2
--        iempty <= '0'; ofull <= '0'; DI <= x"40240000"; wait for T; -- X1
--        iempty <= '0'; ofull <= '0'; DI <= x"00000000"; wait for T; -- X2
--        iempty <= '0'; ofull <= '0'; DI <= x"40000000"; wait for T; -- Y1
--        iempty <= '0'; ofull <= '0'; DI <= x"00000000"; wait for T; -- Y2
--        iempty <= '1'; ofull <= '0'; DI <= x"12345678"; wait for T*70; -- Dummy 
        
--        -- Test Case 2
--        -- X = 2,  Y = 10  Target = power = 2^10
--        iempty <= '0'; ofull <= '0'; DI <= x"40000000"; wait for T; -- X1
--        iempty <= '0'; ofull <= '0'; DI <= x"00000000"; wait for T; -- X2
--        iempty <= '0'; ofull <= '0'; DI <= x"40240000"; wait for T; -- Y1
--        iempty <= '0'; ofull <= '0'; DI <= x"00000000"; wait for T; -- Y2
--        iempty <= '1'; ofull <= '0'; DI <= x"12345678"; wait for T*70; -- Dummy  
		
      wait;
   end process;

END;
