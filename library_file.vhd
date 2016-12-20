library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
package library_file is

  type arr32 is array (integer range <>) of std_logic_vector(31 downto 0);
  type arr16 is array (integer range <>) of std_logic_vector(15 downto 0);
  type arr5 is array (integer range <>) of std_logic_vector(4 downto 0);
  type registerFile is array(0 to 31) of std_logic_vector(31 downto 0);

  type opcode is (
      OP_STALL,
      OP_ADDU,
      OP_ADDIU,
      OP_SUBU,
      OP_SUBIU,
      OP_MULT,
      OP_MULTU,
      OP_AND,
      OP_OR,
      OP_XOR,
      OP_SRL,
      OP_SLL,
      OP_ANDI,
      OP_ORI,
      OP_XORI,
      OP_SLTI,
      OP_SLTIU,
      OP_SRA,
      OP_SLT,
      OP_SLTU,
      OP_MFHI,
      OP_MFLO,
      OP_LW,
      OP_SW,
      OP_LB,
      OP_LBU,
      OP_SB,
      OP_LH,
      OP_LHU,
      OP_SH,
      OP_LWU,
      OP_BEQ,
      OP_BNE,
      OP_BLEZ,
      OP_BGTZ,
      OP_BLTZ,
      OP_BGEZ,
      OP_J,
      OP_JAL,
      OP_JR
  );
  type STATE_TYPE is (
      INCREMENT,
      READ_PC,
      READ_REGFILE,
      FETCH,
      DECODE,
      MEM_ADDR_COMP,
      EXECUTION,
      EXECUTION_1,
      EXECUTION_2,
      BRANCH,
      JUMP,
      READ_MEM,
      LOAD_MEM,
      STORE_MEM,
      WRITE_BACK
  );

  constant A_MUX_PC_REG     : std_logic_vector(1 downto 0)  := "00";
  constant A_MUX_A_REG      : std_logic_vector(1 downto 0)  := "01";
  constant A_MUX_SHIFT      : std_logic_vector(1 downto 0)  := "10";

  constant B_MUX_B_REG      : std_logic_vector(1 downto 0)  := "00";
  constant B_MUX_FOUR       : std_logic_vector(1 downto 0)  := "01";
  constant B_MUX_SIGN_EXT   : std_logic_vector(1 downto 0)  := "10";
  constant B_MUX_SEXT_SHFL  : std_logic_vector(1 downto 0)  := "11";

  constant PC_MUX_ALU       : std_logic_vector(1 downto 0)  := "00";
  constant PC_MUX_ALU_REG   : std_logic_vector(1 downto 0)  := "01";
  constant PC_MUX_IR        : std_logic_vector(1 downto 0)  := "10";
  constant PC_MUX_ZEROS     : std_logic_vector(1 downto 0)  := "11";

  constant WR_DATA_MUX_ALU  : std_logic_vector(1 downto 0)  := "00";
  constant WR_DATA_MUX_MEM  : std_logic_vector(1 downto 0)  := "01";
  constant WR_DATA_MUX_MFHI : std_logic_vector(1 downto 0)  := "10";
  constant WR_DATA_MUX_MFLO : std_logic_vector(1 downto 0)  := "11";

  constant ZERO             : std_logic_vector(31 downto 0) := x"00000000";

  constant CONST_BGEZ       : std_logic_vector(4 downto 0)  := "00001";
  constant CONST_BLTZ       : std_logic_vector(4 downto 0)  := "00000";

  constant CONST_ADDIU      : std_logic_vector(5 downto 0)  := "001001";
  constant CONST_SUBIU      : std_logic_vector(5 downto 0)  := "010000";
  constant CONST_ANDI       : std_logic_vector(5 downto 0)  := "001100";
  constant CONST_BEQ        : std_logic_vector(5 downto 0)  := "000100";
  constant CONST_BGTZ       : std_logic_vector(5 downto 0)  := "000111";
  constant CONST_BLEZ       : std_logic_vector(5 downto 0)  := "000110";
  constant CONST_BNE        : std_logic_vector(5 downto 0)  := "000101";
  constant CONST_LB         : std_logic_vector(5 downto 0)  := "100000";
  constant CONST_LWU        : std_logic_vector(5 downto 0)  := "100111";
  constant CONST_ORI        : std_logic_vector(5 downto 0)  := "001101";
  constant CONST_SB         : std_logic_vector(5 downto 0)  := "101000";
  constant CONST_SH         : std_logic_vector(5 downto 0)  := "101001";
  constant CONST_SLTI       : std_logic_vector(5 downto 0)  := "001010";
  constant CONST_SLTIU      : std_logic_vector(5 downto 0)  := "001011";
  constant CONST_XORI       : std_logic_vector(5 downto 0)  := "001110";

  constant CONST_ADDU       : std_logic_vector(5 downto 0)  := "100001";
  constant CONST_AND        : std_logic_vector(5 downto 0)  := "100100";
  constant CONST_JR         : std_logic_vector(5 downto 0)  := "001000";
  constant CONST_MFHI       : std_logic_vector(5 downto 0)  := "010000";
  constant CONST_MFLO       : std_logic_vector(5 downto 0)  := "010010";
  constant CONST_MULT       : std_logic_vector(5 downto 0)  := "011000";
  constant CONST_MULTU      : std_logic_vector(5 downto 0)  := "011001";
  constant CONST_OR         : std_logic_vector(5 downto 0)  := "100101";
  constant CONST_SLL        : std_logic_vector(5 downto 0)  := "000000";
  constant CONST_SLT        : std_logic_vector(5 downto 0)  := "101010";
  constant CONST_SLTU       : std_logic_vector(5 downto 0)  := "101011";
  constant CONST_SRA        : std_logic_vector(5 downto 0)  := "000011";
  constant CONST_SRL        : std_logic_vector(5 downto 0)  := "000010";
  constant CONST_SUBU       : std_logic_vector(5 downto 0)  := "100011";
  constant CONST_XOR        : std_logic_vector(5 downto 0)  := "100110";

  constant CONST_J          : std_logic_vector(5 downto 0)  := CONST_SRL;
  constant CONST_JAL        : std_logic_vector(5 downto 0)  := CONST_SRA;
  constant CONST_LBU        : std_logic_vector(5 downto 0)  := CONST_AND;
  constant CONST_LH         : std_logic_vector(5 downto 0)  := CONST_ADDU;
  constant CONST_LHU        : std_logic_vector(5 downto 0)  := CONST_OR;
  constant CONST_LW         : std_logic_vector(5 downto 0)  := CONST_SUBU;
  constant CONST_SW         : std_logic_vector(5 downto 0)  := CONST_SLTU;

end package;
