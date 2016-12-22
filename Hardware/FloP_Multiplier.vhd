-- Joshua Mack, Sam Bellestri, Nia Simmonds, IREECE 2015
-- Basic Description:
-- Behavioral floating point multiplier that multiplies arbitrary floating point numbers.
-- Parameters:
--  Generics:
--      expWidth: the width of the exponent field
--      fracWidth: the width of the fractional field
--  Ports:
--      num1, num2: the two numbers being multiplied
--      clk: the clock signal required by nature of this behavioral implementation
--      product: num1 * num2


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

entity FloP_Multiplier is
    Generic ( expWidth : integer := 11; fracWidth : integer := 52 );
    Port ( num1, num2 : in std_logic_vector(expWidth+fracWidth downto 0);
           clk : in std_logic;
           product : out std_logic_vector(expWidth+fracWidth downto 0));
end FloP_Multiplier;

architecture Behavioral of FloP_Multiplier is

    constant expBias : integer := (2**(expWidth-1)-1);

    signal signifProd : std_logic_vector(2*fracWidth+1 downto 0);
    signal signifMSB : std_logic_vector(expWidth downto 0);
    signal expSum : std_logic_vector(expWidth downto 0);
    signal prodSign : std_logic;

begin
    -- pos*pos => pos, etc.
    prodSign <= num1(expWidth+fracWidth) xor num2(expWidth+fracWidth);
    -- ((exp1 - bias) + (exp2 - bias)) + bias = (exp1 + exp2 - bias). signifMSB is for if 1.num1*1.num2 >= 2 => requires shifting.
    signifMSB <= (0 => signifProd(2*fracWidth+1), others => '0');
    expSum <= std_logic_vector(unsigned(num1(expWidth+fracWidth-1 downto fracWidth)) + unsigned(num2(expWidth+fracWidth-1 downto fracWidth)) - to_unsigned(expBias, expWidth+1) + unsigned(signifMSB));
    -- (fracWidth downto 0) * (fracWidth downto 0) size multiplication produces a (2*fracWidth+1 downto 0) size vector
    signifProd <= std_logic_vector(unsigned('1' & num1(fracWidth-1 downto 0)) * unsigned('1' & num2(fracWidth-1 downto 0)));

    p1 : process(clk) begin
        if rising_edge(clk) then
            -- If num1 = 0 or num2 = 0...
            if num1 = std_logic_vector(to_unsigned(0, expWidth+fracWidth+1)) or num2 = std_logic_vector(to_unsigned(0, expWidth+fracWidth+1)) then
                -- Their product is 0
                product <= (others => '0');
            -- Otherwise...
            else
                -- If MSB(signifProd) = 1, then 
                case signifProd(2*fracWidth+1) is
                    -- There needs to be a bit of shifting because the exponent increased by one
                    when '1' => product <= (prodSign & expSum(expWidth-1 downto 0) & signifProd(2*fracWidth downto fracWidth+1));
                    -- Otherwise, no normalization/shifting is required
                    when others => product <= (prodSign & expSum(expWidth-1 downto 0) & signifProd(2*fracWidth-1 downto fracWidth));
                end case;
            end if;
        end if;
    end process;

end Behavioral;
