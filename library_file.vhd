library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
package library_file is

  type arr32 is array (integer range <>) of std_logic_vector(31 downto 0);
  type arr16 is array (integer range <>) of std_logic_vector(15 downto 0);
  type arr5 is array (integer range <>) of std_logic_vector(4 downto 0);
  type registerFile is array(0 to 15) of std_logic_vector(63 downto 0);

  type opcode is (
      ALU_ADDU,
      ALU_SUBU,
      ALU_MULT,
      ALU_MULTU,
      ALU_AND,
      ALU_OR,
      ALU_XOR,
      ALU_SRL,
      ALU_SLL,
      ALU_SRA,
      ALU_SLT,
      ALU_SLTU,
      ALU_MFHI,
      ALU_MFLO,
      ALU_LW,
      ALU_SW,
      ALU_LB,
      ALU_LBU,
      ALU_SB,
      ALU_LH,
      ALU_LHU,
      ALU_SH,
      ALU_LWU,
      ALU_BEQ,
      ALU_BNE,
      ALU_BLEZ,
      ALU_BGTZ,
      ALU_BLTZ,
      ALU_BGEZ,
      ALU_J,
      ALU_JAL,
      ALU_JR
  );

end package;
