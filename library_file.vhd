library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
package library_file is

  type arr32 is array (integer range <>) of std_logic_vector(31 downto 0);
  type arr16 is array (integer range <>) of std_logic_vector(15 downto 0);
  type arr5 is array (integer range <>) of std_logic_vector(4 downto 0);
  type registerFile is array(0 to 31) of std_logic_vector(31 downto 0);

  type opcode is (
      ALU_STALL,
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
  type STATE_TYPE is (
      INIT,
      PC_TO_ADDR,
      ALU_TO_ADDR,
      DECODE,
      REGFILE_TO_AB,
      TO_ALU,
      STORE_ALU
  );
  constant ZERO : std_logic_vector(31 downto 0) := x"00000000";

  -- constant OP_ADDIU : std_logic_vector(5 downto 0) := "001001";
  -- constant OP_ANDI  : std_logic_vector(5 downto 0) := "001100";
  -- constant OP_BEQ   : std_logic_vector(5 downto 0) := "000100";
  -- constant OP_BGEZ  : std_logic_vector(5 downto 0) := "";
  -- constant OP_BGTZ  : std_logic_vector(5 downto 0) := "000111";
  -- constant OP_BLEZ  : std_logic_vector(5 downto 0) := "000110";
  -- constant OP_BLTZ  : std_logic_vector(5 downto 0) := "";
  -- constant OP_BNE   : std_logic_vector(5 downto 0) := "000101";
  -- constant OP_J     : std_logic_vector(5 downto 0) := "000010";
  -- constant OP_JAL   : std_logic_vector(5 downto 0) := "000011";
  -- constant OP_LB    : std_logic_vector(5 downto 0) := "100000";
  -- constant OP_LBU   : std_logic_vector(5 downto 0) := "";
  -- constant OP_LH    : std_logic_vector(5 downto 0) := "";
  -- constant OP_LHU   : std_logic_vector(5 downto 0) := "";
  -- constant OP_LW    : std_logic_vector(5 downto 0) := "";
  -- constant OP_LWU   : std_logic_vector(5 downto 0) := "";
  -- constant OP_ORI   : std_logic_vector(5 downto 0) := "";
  -- constant OP_SB    : std_logic_vector(5 downto 0) := "";
  -- constant OP_SH    : std_logic_vector(5 downto 0) := "";
  -- constant OP_SLTI  : std_logic_vector(5 downto 0) := "";
  -- constant OP_SLTIU : std_logic_vector(5 downto 0) := "";
  -- constant OP_SW    : std_logic_vector(5 downto 0) := "101011";
  -- constant OP_XORI  : std_logic_vector(5 downto 0) := "001110";

  constant OP_ADDU  : std_logic_vector(5 downto 0) := "100001";
  constant OP_AND   : std_logic_vector(5 downto 0) := "100100";
  constant OP_JR    : std_logic_vector(5 downto 0) := "001000";
  constant OP_MFHI  : std_logic_vector(5 downto 0) := "010000";
  constant OP_MFLO  : std_logic_vector(5 downto 0) := "010010";
  constant OP_MULT  : std_logic_vector(5 downto 0) := "011000";
  constant OP_MULTU : std_logic_vector(5 downto 0) := "011001";
  constant OP_OR    : std_logic_vector(5 downto 0) := "100101";
  constant OP_SLL   : std_logic_vector(5 downto 0) := "000000";
  constant OP_SLT   : std_logic_vector(5 downto 0) := "101010";
  constant OP_SLTU  : std_logic_vector(5 downto 0) := "101011";
  constant OP_SRA   : std_logic_vector(5 downto 0) := "000011";
  constant OP_SRL   : std_logic_vector(5 downto 0) := "000010";
  constant OP_SUBU  : std_logic_vector(5 downto 0) := "100011";
  constant OP_XOR   : std_logic_vector(5 downto 0) := "100110";

end package;
