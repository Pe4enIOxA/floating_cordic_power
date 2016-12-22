-- LUT for mneg, Kazumi Malhan, Final Project
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- LUT using multiplexer.
entity my_negLUT is
   generic (N: INTEGER:= 16);
	port (s: in std_logic_vector (2 downto 0);
	      y: out std_logic_vector (N-1 downto 0));
end my_negLUT;

architecture structure of my_negLUT is

signal a0,a1,a2,a3,a4,a5: std_logic_vector(N-1 downto 0);

begin
    -- These values are pre-calculated using MATLAB
bit32: if (N = 32) generate
        a0 <= x"3f791395";
        a1 <= x"3fad50b2";
        a2 <= x"3fdbc672";
        a3 <= x"4004948f";
        a4 <= x"401b0395";
        a5 <= x"40315208";
        end generate;

bit64: if (N = 64) generate
        a0 <= x"3fef2272ae325a57";
        a1 <= x"3ff5aa16394d481f";
        a2 <= x"3ffb78ce48912b5a";
        a3 <= x"40009291e8e3181b";
        a4 <= x"4003607294602e42";
        a5 <= x"40062a40fda3e3cc";
        end generate;
        
bit24: if (N = 24) generate
        a0 <= "001111101111001000100111";
        a1 <= "001111110101101010100001";
        a2 <= "001111111011011110001100";
        a3 <= "010000000000100100101001";
        a4 <= "010000000011011000000111";
        a5 <= "010000000110001010100100";
        end generate;
        
bit16: if (N = 16) generate
        a0 <= "0011110111100100";
        a1 <= "0011111010110101";
        a2 <= "0011111101101111";
        a3 <= "0100000000010010";
        a4 <= "0100000001101100";
        a5 <= "0100000011000101";
        end generate;
    
	with s select
		y <=   a0 when "010",
			   a1 when "011",
			   a2 when "100",
			   a3 when "101",
			   a4 when "110",
			   a5 when others;
			 
end structure;