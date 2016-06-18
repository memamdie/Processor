---- ---- ---- ---- ---- ----
---- ----    REG    ---- ----
---- ---- ---- ---- ---- ----
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.library_file.all;
entity reg is
  generic (
    width  :     positive := 32);
  port (
    clk    : in  std_logic;
    rst    : in  std_logic;
    en   : in  std_logic;
    input  : in  std_logic_vector(width-1 downto 0);
    output : out std_logic_vector(width-1 downto 0));
end reg;


architecture BHV of reg is
begin
  process(clk, rst)
  begin
    if (rst = '1') then
      output   <= (others => '0');
    elsif rising_edge(clk) then
      if (en = '1') then
        output <= input;
      end if;
    end if;
  end process;
end BHV;



---- ---- ---- ---- ---- ----
---- ---     MUX     --- ----
---- ---- ---- ---- ---- ----
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.library_file.all;
entity mux32 is
  generic (
    width  :     positive := 2);
  port (
    inputs : in  arr32(0 to width-1);
    sel    : in  std_logic_vector((integer(ceil(log2(real(width))))-1) downto 0);
    output : out std_logic_vector(31 downto 0));
end entity;

architecture arch of mux32 is
begin
  output <= inputs(to_integer(unsigned(sel)));
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.library_file.all;
entity mux4x1 is
  port (
    in1, in2, in3, in4 : in std_logic_vector(31 downto 0);
    sel                : in std_logic_vector(1 downto 0);
    output             : out std_logic_vector(31 downto 0)
  );
end entity;

architecture arch of mux4x1 is
  begin

    process(sel, in1, in2, in3, in4)
    begin
      case( sel ) is

      when "00" =>
        output <= in1;

      when "01" =>
        output <= in2;

      when "10" =>
        output <= in3;

      when "11" =>
        output <= in4;

      when others => null;

      end case;
    end process;

end architecture;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.library_file.all;
entity mux5 is
  generic (
    width  :     positive := 2);
  port (
    inputs : in  arr5(0 to width-1);
    sel    : in  std_logic_vector((integer(ceil(log2(real(width))))-1) downto 0);
    output : out std_logic_vector(4 downto 0));
end entity;

architecture arch of mux5 is
begin
  output <= inputs(to_integer(unsigned(sel)));
end architecture;

---- ---- ---- ---- ---- ----
---- ----Sign Extend---- ----
---- ---- ---- ---- ---- ----
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.library_file.all;
entity sign_extender is
  port (
    input  : in std_logic_vector(15 downto 0);
    output : out std_logic_vector(31 downto 0)
  );
end entity;

architecture arch of sign_extender is
begin
  output <= std_logic_vector(resize(signed(input), 32));
end architecture;


---- ---- ---- ---- ---- ----
---- ----Shift Left ---- ----
---- ---- ---- ---- ---- ----
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.library_file.all;
entity shift_l is
  generic ( width : positive := 32);
  port (
    input  : in std_logic_vector(width-1 downto 0);
    num    : in natural;
    output : out std_logic_vector(width-1 downto 0)
  );
end entity;

architecture arch of shift_l is
begin
    output <= std_logic_vector(SHIFT_LEFT(unsigned(input), num));
end architecture;


---- ---- ---- ---- ---- ----
---- ---- -- ALU -- ---- ----
---- ---- ---- ---- ---- ----
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.library_file.all;


entity ALU is
  generic ( width : positive := 32);
  port (
    in1, in2              : in std_logic_vector(width-1 downto 0);
    sel                   : in opcode;
    output                : out std_logic_vector(width-1 downto 0);
    toBranchOrNotToBranch : out std_logic
  );
end entity;

architecture arch of ALU is
begin
  COMBINATIONAL : process(in1, in2, sel)
    variable temp    : unsigned(width downto 0);
  begin
	  temp                  := (others => '0');
    output                <= (others => '0');
    toBranchOrNotToBranch <= '0';
    case sel is
        when OP_ADDU  =>
          temp := resize(unsigned(in1), width+1) + resize(unsigned(in2), width+1);
        when OP_SUBU  =>
          temp := resize(unsigned(in1), width+1) + resize(unsigned(in2), width+1);
        when OP_MULT  =>
          temp := unsigned(resize(signed(in1)*signed(in2), width+1));
        when OP_MULTU =>
          temp := resize(unsigned(in1)*unsigned(in2), width+1);
        when OP_AND   =>
          temp := (resize(unsigned(in1), width+1)) and (resize(unsigned(in2), width+1));
        when OP_OR    =>
          temp := (resize(unsigned(in1), width+1)) or (resize(unsigned(in2), width+1));
        when OP_XOR   =>
          temp := (resize(unsigned(in1), width+1)) xor (resize(unsigned(in2), width+1));
        when OP_SRL   =>
          temp := SHIFT_RIGHT(resize(unsigned(in1), width+1), to_integer(unsigned(in2)));
        when OP_SLL   =>
          temp := SHIFT_LEFT(resize(unsigned(in1), width+1), to_integer(unsigned(in2)));
        when OP_SRA   =>
          temp := unsigned(SHIFT_RIGHT(resize(signed(in1), width+1), to_integer(unsigned(in2))));
        when OP_SLT   =>
          if in1 < in2 then
              temp := to_unsigned(1, temp'length);
          end if;
        when OP_SLTU  =>
          if ('0' & in1) < ('0' & in2) then
              temp := to_unsigned(1, temp'length);
          end if;
        -- when OP_MFHI  =>
        -- when OP_MFLO  =>
        -- when OP_LW    =>
        -- when OP_SW    =>
        -- when OP_LB    =>
        -- when OP_LBU   =>
        -- when OP_SB    =>
        -- when OP_LH    =>
        -- when OP_LHU   =>
        -- when OP_SH    =>
        -- when OP_LWU   =>
        when OP_BEQ   =>
          if in1 = in2 then
            toBranchOrNotToBranch <= '1';
          end if;
        when OP_BNE   =>
          if in1 /= in2 then
            toBranchOrNotToBranch <= '1';
          end if;
        when OP_BLEZ  =>
          if in1 <= ZERO then
            toBranchOrNotToBranch <= '1';
          end if;
        when OP_BGTZ  =>
          if in1 > ZERO then
            toBranchOrNotToBranch <= '1';
          end if;
        when OP_BLTZ  =>
          if in1 < ZERO then
            toBranchOrNotToBranch <= '1';
          end if;
        when OP_BGEZ  =>
          if in1 >= ZERO then
            toBranchOrNotToBranch <= '1';
          end if;
        -- when OP_J     =>
        -- when OP_JAL   =>
        -- when OP_JR    =>
        when others    => null;
    end case;
    output <= std_logic_vector(resize(temp, width));
  end process;
end architecture;



---- ---- ---- ---- ---- ----
---- ---Register File--- ----
---- ---- ---- ---- ---- ----
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.library_file.all;

entity register_file is
  port(
    outA        : out std_logic_vector(31 downto 0);
    outB        : out std_logic_vector(31 downto 0);
    input       : in  std_logic_vector(31 downto 0);
    writeEnable : in  std_logic;
    regASel     : in  std_logic_vector(4 downto 0);
    regBSel     : in  std_logic_vector(4 downto 0);
    writeRegSel : in  std_logic_vector(4 downto 0);
    clk         : in  std_logic
    );
end register_file;


architecture behavioral of register_file is
  signal registers : registerFile := (others => (others => '0'));
begin
  regFile : process (clk, registers, regASel, regBSel, writeEnable) is
  begin
    -- outA <= ZERO;
    -- outB <= ZERO;
    if rising_edge(clk) then
      -- Read A and B before bypass
      outA <= registers(to_integer(unsigned(regASel)));
      outB <= registers(to_integer(unsigned(regBSel)));
      -- Write and bypass
      if writeEnable = '1' then
        registers(to_integer(unsigned(writeRegSel))) <= input;  -- Write
        if regASel = writeRegSel then  -- Bypass for read A
          outA <= input;
        end if;
        if regBSel = writeRegSel then  -- Bypass for read B
          outB <= input;
        end if;
      end if;
    end if;
  end process;
end behavioral;
