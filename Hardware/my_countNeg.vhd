---------------------------------------------------------------------------
-- This VHDL file was developed by Daniel Llamocca (2013).  It may be
-- freely copied and/or distributed at no cost.  Any persons using this
-- file for any purpose do so at their own risk, and are responsible for
-- the results of such use.  Daniel Llamocca does not guarantee that
-- this file is complete, correct, or fit for any particular purpose.
-- NO WARRANTY OF ANY KIND IS EXPRESSED OR IMPLIED.  This notice must
-- accompany any copy of this file.
--------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;

entity my_countNeg is
	port ( clock, resetn, E, sclr: in std_logic;
			 Q: out integer;
			 z: out std_logic);
end my_countNeg;

architecture Behavioral of my_countNeg is
	signal Qt: integer range 0 to 5;
begin

	process (resetn, clock, E, sclr)
	begin
		if resetn = '0' then
			Qt <= 5;
		elsif (clock'event and clock = '1') then
			if E = '1' then
				if sclr = '1' then
					Qt <= 5;
				else
					if Qt = 0 then
						Qt <= 5;
					else
						Qt <= Qt - 1;
					end if;
				end if;
			end if;
		end if;
	end process;
	Q <= Qt;

	z <= '1' when Qt = 0 else '0';
end Behavioral;
