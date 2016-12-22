---------------------------------------------------------------------------
-- This VHDL file was developed by Daniel Llamocca (2013).  It may be
-- freely copied and/or distributed at no cost.  Any persons using this
-- file for any purpose do so at their own risk, and are responsible for
-- the results of such use.  Daniel Llamocca does not guarantee that
-- this file is complete, correct, or fit for any particular purpose.
-- NO WARRANTY OF ANY KIND IS EXPRESSED OR IMPLIED.  This notice must
-- accompany any copy of this file.
--------------------------------------------------------------------------

-- BusMux Kazumi Malhan Final Project
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity busMux is
   generic (N: INTEGER:= 20); -- Length of each input signal
	port (a,b: in std_logic_vector (N-1 downto 0);
	      s: in std_logic;
	      y: out std_logic_vector (N-1 downto 0));
end busMux;

architecture structure of busMux is

begin

	with s select
		y <= a when '0',
			 b when others;
			 
end structure;

