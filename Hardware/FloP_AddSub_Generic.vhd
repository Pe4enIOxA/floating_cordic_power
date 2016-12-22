----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/27/2015 10:30:25 AM
-- Design Name: 
-- Module Name: EightBitFPAdder_top - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

------------------Done? : Not yet.
    --------What to do about the priority encoder width?


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.MATH_REAL."ceil";
use IEEE.MATH_REAL."log2";

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FloP_AddSub_Generic is
    Generic ( expWidth : integer := 11; fracWidth : integer := 52 );
    Port ( input1 : in std_logic_vector (expWidth+fracWidth downto 0);
         input2 : in std_logic_vector (expWidth+fracWidth downto 0);
         addSub : in std_logic;
         sum : out std_logic_vector (expWidth+fracWidth downto 0));
end FloP_AddSub_Generic;

architecture Behavioral of FloP_AddSub_Generic is

    constant dataWidth : integer := expWidth+fracWidth+1;
--    constant fracWidthPlus1 : integer := fracWidth+1;
    constant pEncOutWidth : integer := integer(ceil(log2(real(fracWidth))))+1;

    component Comparator_Generic is 
        Generic ( dataWidth : integer );
        Port ( a, b : in std_logic_vector(dataWidth-1 downto 0);
               lt, eq, gt : out std_logic ); 
    end component;
    
    component Adder_Generic is
        Generic ( dataWidth : integer );
        Port ( num1 : in STD_LOGIC_VECTOR (dataWidth-1 downto 0);
               num2 : in STD_LOGIC_VECTOR (dataWidth-1 downto 0);
               carryIn : in STD_LOGIC;
               sum : out STD_LOGIC_VECTOR (dataWidth-1 downto 0);
               carryOut : out STD_LOGIC);
    end component;
    
    -- TODO: Make this better and not limited to only two inputs. Figure out some kind of generic array type.
    component Mux_Generic is
        Generic ( dataWidth : integer ); --selectWidth : integer);
        Port ( dataIn1 : in std_logic_vector (dataWidth-1 downto 0);
               dataIn2 : in std_logic_vector (dataWidth-1 downto 0);
--               selectIn : in std_logic_vector (selectWidth-1 downto 0);
               selectIn : in std_logic;
               dataOut : out std_logic_vector (dataWidth-1 downto 0));
    end component;
    
    component BarrelShifter_Generic is
        Generic ( dataWidth : integer; shiftWidth : integer );
        Port ( inputData : in std_logic_vector(dataWidth-1 downto 0);
             shiftAmt : in std_logic_vector(shiftWidth-1 downto 0);
             leftRight : in std_logic;
             outputData : out std_logic_vector(dataWidth-1 downto 0));
    end component;
    
--    component PriorityEncoder_53B is
--        Port ( input : in std_logic_vector(52 downto 0); enable : in std_logic;
--               output : out std_logic_vector(5 downto 0) );
--    end component;
    component PriorityEncoder_Generic is
        Generic ( inputWidth : integer; outputWidth : integer );
        Port ( input : in STD_LOGIC_VECTOR (inputWidth-1 downto 0);
               enable : in STD_LOGIC;
               output : out STD_LOGIC_VECTOR (outputWidth-1 downto 0) );
    end component;


    --Signals to hold the two numbers s.t. num1 >= num2 always.
    signal num1 : std_logic_vector (dataWidth-1 downto 0) := input1;
    signal num2 : std_logic_vector (dataWidth-1 downto 0) := input2;
    -- The less than, equal to, and greater than output signals for exponent comparison and significand comparison.
    signal expLt, expEq, expGt, sigLt, sigEq, sigGt : std_logic;
    -- Signal for storing the select bit of the mux that orders the inputs s.t. num1 >= num2 always.
    signal inputMuxSel : std_logic;
    -- 2's Complement of Exponent 2 for subtraction.
    signal negExp2 : std_logic_vector (expWidth-1 downto 0);
    -- The difference of the two exponents.
    signal expDiff : std_logic_vector (expWidth-1 downto 0);
    -- The shifted significand of num2, including its hidden '1'.
    signal shiftedSig2 : std_logic_vector (fracWidth downto 0);
    -- The complemented version of num1's significand, including the '1'.
    signal negSig1 : std_logic_vector (fracWidth downto 0);
    -- The complemented version of num2's shifted significand.
    signal negSig2 : std_logic_vector (fracWidth downto 0);
    -- The mux outputs ready to go to the adder.
    signal adderNum1, adderNum2 : std_logic_vector (fracWidth downto 0);
    -- Output of the adder.
    signal sigSum : std_logic_vector (fracWidth downto 0);
    -- Carry Out of the adder.
    signal sigCout : std_logic;
    -- Priority Encoder output and its negation.
    signal pEncOut, negPEnc : std_logic_vector (pEncOutWidth-1 downto 0);
    -- Difference between exp1 and PEncoder output
    signal exp1Diff : std_logic_vector (expWidth-1 downto 0);
    -- The final exponents for addition and subtraction, as well as the final exponent var.
    signal finalExpSub, finalExpAdd1, finalExpAdd2, finalExp : std_logic_vector (expWidth-1 downto 0);
    -- The final significand, ready for output.
    signal finalSigSub, finalSigAdd, finalSig : std_logic_vector (fracWidth downto 0);
    -- Sign of the output.
    signal outputSign : std_logic_vector(0 downto 0);
    -- Output of comparator checking if num2 == 0
    signal eqZero : std_logic;
    -- Output of num2EqZeroMux
    signal num2EqZeroMuxOut : std_logic_vector(dataWidth-1 downto 0);
    
begin
    ---------------------Compare the incoming numbers and order them such that num1 >= num2--------------------
    -- Compare the exponents of the incoming numbers.
    expComparator : Comparator_Generic Generic Map(dataWidth => expWidth)
               Port Map(a => input1(expWidth+fracWidth-1 downto fracWidth), b => input2(expWidth+fracWidth-1 downto fracWidth), lt => expLt, eq => expEq, gt => expGt);
    -- Compare the significands of the incoming numbers.
    sigComparator : Comparator_Generic Generic Map(dataWidth => fracWidth)
               Port Map(a => input1(fracWidth-1 downto 0), b => input2(fracWidth-1 downto 0), lt => sigLt, eq => sigEq, gt => sigGt);
    -- Choose the mux select bit s.t. num1 >= num2.
    inputMuxSel <= (expLt or (expEq and sigLt));
    -- Mux for selecting num1.
    inputMux1 : Mux_Generic Generic Map(dataWidth => dataWidth)
               Port Map(dataIn1 => input1, dataIn2 => input2, selectIn => inputMuxSel, dataOut => num1);
    -- Mux for selecting num2.
    inputMux2 : Mux_Generic Generic Map(dataWidth => dataWidth)
               Port Map(dataIn1 => input2, dataIn2 => input1, selectIn => inputMuxSel, dataOut => num2);
    -------------Find the difference in the exponents and perform shifting of num2 to match them--------------
    -- Complement the exponent of num2.
    exp21Compl : Adder_Generic Generic Map(dataWidth => expWidth)
               Port Map(num1 => (others => '0'), num2 => not(num2(expWidth+fracWidth-1 downto fracWidth)), carryIn => '1', sum => negExp2);
    -- Add it to the exponent of num1 to find the difference.
    expSubtr : Adder_Generic Generic Map(dataWidth => expWidth)
               Port Map(num1 => num1(expWidth+fracWidth-1 downto fracWidth), num2 => negExp2, carryIn => '0', sum => expDiff);
    -- Shift sig2, including its hidden '1' bit, by that difference to normalize it.
    num2Shift : BarrelShifter_Generic Generic Map(dataWidth => fracWidth+1, shiftWidth => expWidth)
               Port Map(inputData => ('1' & num2(fracWidth-1 downto 0)), shiftAmt => expDiff, leftRight => '1', outputData => shiftedSig2);
    ------------------------2's Complement any input that needs it before addition---------------------------
    -- Complement significand 1
    sig1Compl : Adder_Generic Generic Map(dataWidth => fracWidth+1)
               Port Map(num1 => not('1' & num1(fracWidth-1 downto 0)), num2 => (others => '0'), carryIn => '1', sum => negSig1);
    -- Complement significand 2
    sig2Compl : Adder_Generic Generic Map(dataWidth => fracWidth+1)
               Port Map(num1 => not(shiftedSig2), num2 => (others => '0'), carryIn => '1', sum => negSig2);
    -- Mux to choose whether or not to pass in the positive or negative version of sig1 to the adder.
    additionMux1 : Mux_Generic Generic Map(dataWidth => fracWidth+1)
               Port Map(dataIn1 => ('1' & num1(fracWidth-1 downto 0)), dataIn2 => negSig1, selectIn => num1(dataWidth-1), dataOut => adderNum1);
    -- Mux to choose whether or not to pass in the positive or negative version of sig2 to the adder.
    additionMux2 : Mux_Generic Generic Map(dataWidth => fracWidth+1)
               Port Map(dataIn1 => shiftedSig2, dataIn2 => negSig2, selectIn => (num2(dataWidth-1) xor addSub), dataOut => adderNum2);
    -----------------------Add the numbers and perform any necessary normalization-----------------------
    -- Adder that adds/subtracts the significands
    significandAdder : Adder_Generic Generic Map(dataWidth => fracWidth+1)
               Port Map(num1 => adderNum1, num2 => adderNum2, carryIn => '0', sum => sigSum, carryOut => sigCout);
    -- Priority encoder to determine how much to shift in order to normalize.
--    priorEnc : PriorityEncoder_53B Port Map(input => sigSum, enable => addSub, output => pEncOut);
    priorEnc : PriorityEncoder_Generic Generic Map(inputWidth => fracWidth+1, outputWidth => pEncOutWidth)
               Port Map(input => sigSum, enable => addSub, output => pEncOut);
    -- 2's Complementer for complementing pEncOut.
    pEncCompl : Adder_Generic Generic Map(dataWidth => pEncOutWidth)
               Port Map(num1 => not(pEncOut), num2 => (others => '0'), carryIn => '1', sum => negPEnc);
    -- Adder to find difference between pEncOut and exp1.
    normalizeExp : Adder_Generic Generic Map(dataWidth => expWidth)
               Port Map(num1(pEncOutWidth-1 downto 0) => (negPEnc), num1(expWidth-1 downto pEncOutWidth) => (others => negPEnc(pEncOutWidth-1)), 
                        num2 => num1(expWidth+fracWidth-1 downto fracWidth), carryIn => '0', sum => finalExpSub);
    -- If addSum = 1, then we need to use the adder's method of determining when to shift.
    -- Incrementer
    expIncrememter : Adder_Generic Generic Map(dataWidth => expWidth)
               Port Map(num1 => num1(expWidth+fracWidth-1 downto fracWidth), num2 => (others => '0'), carryIn => '1', sum => finalExpAdd1);
    -- Mux to select between the original exponent and the incremented exponent based on Cout.
    adderExpMux : Mux_Generic Generic Map(dataWidth => expWidth)
               Port Map(dataIn1 => num1(expWidth+fracWidth-1 downto fracWidth), dataIn2 => finalExpAdd1, selectIn => sigCout, dataOut => finalExpAdd2);
    -- Mux to select between the exponent needed for addition and the exponent needed for subtraction.
    addSubExpMux : Mux_Generic Generic Map(dataWidth => expWidth) 
               Port Map(dataIn1 => finalExpAdd2, dataIn2 => finalExpSub, selectIn => addSub, dataOut => finalExp);
    -- Shifter to shift sigSum left until it is normalized.
    sigSumSubShift : BarrelShifter_Generic Generic Map(dataWidth => fracWidth+1, shiftWidth => pEncOutWidth)
               Port Map(inputData => sigSum, shiftAmt => pEncOut, leftRight => '0', outputData => finalSigSub);
    -- Shifter to shift sigSum right until it is normalized.
    sigSumAddShift : BarrelShifter_Generic Generic Map(dataWidth => fracWidth+1, shiftWidth => 1)
               Port Map(inputData => sigSum, shiftAmt(0) => sigCout, leftRight => '1', outputData => finalSigAdd);
    -- Final mux to select between added significand depending on addSub mode.
    addSubSigMux : Mux_Generic Generic Map(dataWidth => fracWidth+1)
               Port Map(dataIn1 => finalSigAdd, dataIn2 => finalSigSub, selectIn => addSub, dataOut => finalSig);
    -- Finally, build together the final output.
    outputSign(0) <= (not(inputMuxSel) and input1(dataWidth-1)) or (inputMuxSel and (input2(dataWidth-1) or addSub));
    
    -- Comparator to check if num2 == 0
    num2EqualsZero : Comparator_Generic Generic Map(dataWidth => dataWidth-1)
               Port Map(a => num2(dataWidth-2 downto 0), b => (others => '0'), eq => eqZero);
               
    -- Mux to take care of num2 being zero
    num2EqualsZeroMux : Mux_Generic Generic Map(dataWidth => dataWidth)
               Port Map(dataIn1 => (outputSign(0) & finalExp & finalSig(fracWidth-1 downto 0)), dataIn2 => outputSign(0) & num1(dataWidth-2 downto 0),
                        selectIn => eqZero, dataOut => num2EqZeroMuxOut);
    
    -- Last mux to take care of the case of "x - x = 0"
    equalNumsAndSubtractMux : Mux_Generic Generic Map(dataWidth => dataWidth)
               Port Map(dataIn1 => num2EqZeroMuxOut, dataIn2 => (others => '0'),
                        selectIn => (expEq and sigEq and addSub), dataOut => sum);
                                    
end Behavioral;
