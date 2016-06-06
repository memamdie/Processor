---- ---- ---- ---- ---- ----
---- ----  Datapath ---- ----
---- ---- ---- ---- ---- ----
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.library_file.all;
entity datapath is
  port (
  clk, rst                                                   : in std_logic;
  mem_en, pc_en, a_en, b_en, ir_en, alu_en, wren, regfile_en : in std_logic;
  alu_sel                                                    : in opcode;
  mem_sel, a_sel, wr_reg_sel, wr_data_sel                    : in std_logic_vector(0 downto 0);
  b_sel, pc_sel                                              : in std_logic_vector(1 downto 0);
  immediate                                                  : out std_logic;
  instruction                                                : out opcode
  );
end entity;

architecture arch of datapath is

  signal PC_in, PC_out, IR_in, IR_out, MEM_REG_out, mem_address_in                        : std_logic_vector(31 downto 0);
  signal ALU_in, ALU_out, A_in, A_out, B_in, B_out, in1, in2, signext_out, left_shift_out : std_logic_vector(31 downto 0);
  signal write_data                                                                       : std_logic_vector(31 downto 0);
  signal write_reg                                                                        : std_logic_vector(4 downto 0);
  signal mem_mux_inputs, a_mux_inputs, wr_data_mux_inputs                                 : arr32(0 to 1);
  signal b_mux_inputs, pc_mux_inputs                                                      : arr32(0 to 3);
  signal wr_reg_mux_inputs                                                                : arr5(0 to 1);
  signal instructionSig                                                                   : opcode;
  begin
    mem_mux_inputs     <= (PC_out, ALU_out);
    wr_reg_mux_inputs  <= (IR_out(20 downto 16), IR_out(15 downto 11));
    wr_data_mux_inputs <= (ALU_out, MEM_REG_out);
    b_mux_inputs       <= (B_out, x"00000001", signext_out, left_shift_out);
    a_mux_inputs       <= (PC_out, A_out);
    pc_mux_inputs      <= (ALU_in, ALU_out, (x"0" & IR_out(25 downto 0) & "00"), ZERO);
    instruction        <= instructionSig;

    U_PC : entity work.reg
    port map (
    clk      => clk,
    en       => pc_en,
    rst      => rst,
    input    => PC_in,
    output   => PC_out
    );
    U_PC_MUX : entity work.mux32
    generic map (width => 4)
    port map  (
    inputs   => pc_mux_inputs,
    sel      => pc_sel,
    output   => PC_in
    );
    U_MEM_ADDR_MUX : entity work.mux32
    port map  (
    inputs   => mem_mux_inputs,
    sel      => mem_sel,
    output   => mem_address_in
    );
    U_IR : entity work.reg
    port map (
    clk      => clk,
    en       => ir_en,
    rst      => rst,
    input    => IR_in,
    output   => IR_out
    );
    U_MEM_REG : entity work.reg
    port map (
    clk      => clk,
    en       => mem_en,
    rst      => rst,
    input    => IR_in,
    output   => MEM_REG_out
    );
    U_ALU_REG : entity work.reg
    port map (
    clk      => clk,
    en       => alu_en,
    rst      => rst,
    input    => ALU_in,
    output   => ALU_out
    );
    U_A : entity work.reg
    port map (
    clk      => clk,
    en       => a_en,
    rst      => rst,
    input    => A_in,
    output   => A_out
    );
    U_B : entity work.reg
    port map (
    clk      => clk,
    en       => b_en,
    rst      => rst,
    input    => B_in,
    output   => B_out
    );
    U_A_MUX : entity work.mux32
    port map (
    inputs   => a_mux_inputs,
    sel      => a_sel,
    output   => in1
    );
    U_B_MUX : entity work.mux32
    generic map ( width => 4)
    port map (
    inputs   => b_mux_inputs,
    sel      => b_sel,
    output   => in2
    );
    U_SIGN_EXTEND : entity work.sign_extender
    port map (
    input  => IR_out(15 downto 0),
    output => signext_out
    );
    U_SHIFT_LEFT1 : entity work.shift_l
    port map (
    input    => signext_out,
    num      => 2,
    output   => left_shift_out
    );
    U_WRITE_REG_MUX : entity work.mux5
    port map (
    inputs   => wr_reg_mux_inputs,
    sel      => wr_reg_sel,
    output   => write_reg
    );
    U_WRITE_DATA_MUX : entity work.mux32
    port map (
    inputs   => wr_data_mux_inputs,
    sel      => wr_data_sel,
    output   => write_data
    );
    U_ALU : entity work.ALU
    port map (
    in1      => in1,
    in2      => in2,
    sel      => alu_sel,
    output   => ALU_in
    );
    U_MEMORY : entity work.ram
    port map (
    address		=> PC_out(7 downto 0),
    clock		  => clk,
    data		  => B_out,
    wren		  => wren,
    q		      => IR_in
    );
    U_REGFILE : entity work.register_file
    port map (
    outA        => A_in,
    outB        => B_in,
    input       => write_data,
    writeEnable => regfile_en,
    regASel     => IR_out(25 downto 21),
    regBSel     => IR_out(20 downto 16),
    writeRegSel => write_reg,
    clk         => clk
    );
    process(IR_out)
    begin
      immediate <= '0';
      if IR_out(31 downto 26) = "000000" then
        case( IR_out(5 downto 0) ) is
          when CONST_ADDU =>
          instructionSig <= OP_ADDU;
          when CONST_AND =>
          instructionSig <= OP_AND;
          when CONST_JR =>
          instructionSig <= OP_JR;
          when CONST_MFHI =>
          instructionSig <= OP_MFHI;
          when CONST_MFLO =>
          instructionSig <= OP_MFLO;
          when CONST_MULT =>
          instructionSig <= OP_MULT;
          when CONST_MULTU =>
          instructionSig <= OP_MULTU;
          when CONST_OR =>
          instructionSig <= OP_OR;
          when CONST_SLL =>
          instructionSig <= OP_SLL;
          when CONST_SLT =>
          instructionSig <= OP_SLT;
          when CONST_SLTU =>
          instructionSig <= OP_SLTU;
          when CONST_SRA =>
          instructionSig <= OP_SRA;
          when CONST_SRL =>
          instructionSig <= OP_SRL;
          when CONST_SUBU =>
          instructionSig <= OP_SUBU;
          when CONST_XOR =>
          instructionSig <= OP_XOR;
          when others =>
          instructionSig <= OP_STALL;
        end case;

      elsif IR_out(31 downto 26) = "000001"  then
        case( IR_out(20 downto 16) ) is
          when CONST_BLTZ =>
            instructionSig <= OP_BLTZ;
          when CONST_BGEZ =>
            instructionSig <= OP_BGEZ;
          when others =>
            instructionSig <= OP_STALL;
        end case;

      else
        immediate <= '1';
        case( IR_out(31 downto 26) ) is
          when CONST_ADDIU =>
            instructionSig <= OP_ADDU;
          when CONST_ANDI =>
            instructionSig <= OP_AND;
          when CONST_BEQ =>
            instructionSig <= OP_BEQ;
          when CONST_BGTZ =>
            instructionSig <= OP_BGTZ;
          when CONST_BLEZ =>
            instructionSig <= OP_BLEZ;
          when CONST_BNE =>
            instructionSig <= OP_BNE;
          when CONST_LB =>
            instructionSig <= OP_LB;
          when CONST_LBU =>
            instructionSig <= OP_LBU;
          when CONST_LH =>
            instructionSig <= OP_LH;
          when CONST_LW =>
            instructionSig <= OP_LW;
          when CONST_LWU =>
            instructionSig <= OP_LWU;
          when CONST_ORI =>
            instructionSig <= OP_OR;
          when CONST_SB =>
            instructionSig <= OP_SB;
          when CONST_SLTI =>
            instructionSig <= OP_SLT;
          when CONST_SLTIU =>
            instructionSig <= OP_SLTU;
          when CONST_SW =>
            instructionSig <= OP_SW;
          when CONST_XORI =>
            instructionSig <= OP_XOR;
          when others =>
          instructionSig <= OP_STALL;
        end case;
      end if;

    end process;

  end architecture;
