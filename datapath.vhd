---- ---- ---- ---- ---- ----
---- ----  Datapath ---- ----
---- ---- ---- ---- ---- ----
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.library_file.all;
entity datapath is
  generic (width : positive := 32);
  port (
  clk, rst, jump_link                               : in std_logic;
  mem_en, pc_write, a_en, b_en, ir_en               : in std_logic;
  alu_en, wren, regfile_en, pc_write_cond, alu_zero : in std_logic;
  alu_sel                                           : in opcode;
  mem_sel, wr_reg_sel, wr_data_sel                  : in std_logic_vector(0 downto 0);
  a_sel, b_sel, pc_sel                              : in std_logic_vector(1 downto 0);
  toBranchOrNotToBranch                             : out std_logic;
  instruction, program_counter                      : out std_logic_vector(width-1 downto 0)
  );
end entity;

architecture arch of datapath is

  signal PC_in, PC_out, IR_in, IR_out, MEM_REG_out, mem_address_in : std_logic_vector(31 downto 0);
  signal ALU_in, ALU_out, A_in, A_out, B_in, B_out                 : std_logic_vector(31 downto 0);
  signal alu_in1, alu_in2, signext_out, left_shift_out             : std_logic_vector(31 downto 0);
  signal write_data                                                : std_logic_vector(31 downto 0);
  signal write_reg                                                 : std_logic_vector(4 downto 0);
  signal wr_reg_mux_inputs                                         : arr5(0 to 1);
  signal mem_mux_inputs, wr_data_mux_inputs                        : arr32(0 to 1);
  signal a_mux_inputs                                              : arr32(0 to 2);
  signal b_mux_inputs, pc_mux_inputs                               : arr32(0 to 3);
  signal pc_en                                                     : std_logic;

  begin

    mem_mux_inputs     <= (PC_out, ALU_out);
    wr_reg_mux_inputs  <= (IR_out(20 downto 16), IR_out(15 downto 11));
    wr_data_mux_inputs <= (ALU_out, MEM_REG_out);
    a_mux_inputs       <= (PC_out, A_out, ("000" & x"000000" & IR_out(10 downto 6)));
    b_mux_inputs       <= (B_out, x"00000004", signext_out, left_shift_out);
    pc_mux_inputs      <= (ALU_in, ALU_out, (x"0" & IR_out(25 downto 0) & "00"), ZERO);
    instruction        <= IR_out;
    program_counter    <= PC_out;
    pc_en              <= pc_write or (pc_write_cond and alu_zero);

    U_PC : entity work.reg
    port map (
    clk      => clk,
    en       => pc_en,
    rst      => rst,
    input    => PC_in,
    output   => PC_out
    );
    U_PC_IN_MUX : entity work.mux32
    generic map (width => 4)
    port map  (
    inputs   => pc_mux_inputs,
    sel      => pc_sel,
    output   => PC_in
    );
    U_MEM_IN_MUX : entity work.mux32
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
    U_A_OUT_MUX : entity work.mux32
    generic map ( width => 3)
    port map (
    inputs   => a_mux_inputs,
    sel      => a_sel,
    output   => alu_in1
    );
    U_B_OUT_MUX : entity work.mux32
    generic map ( width => 4)
    port map (
    inputs   => b_mux_inputs,
    sel      => b_sel,
    output   => alu_in2
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
    in1                   => alu_in1,
    in2                   => alu_in2,
    sel                   => alu_sel,
    output                => ALU_in,
    toBranchOrNotToBranch => toBranchOrNotToBranch
    );
    U_MEMORY : entity work.ram
    port map (
    address		=> mem_address_in(7 downto 0),
    clock		  => clk,
    data		  => B_out,
    wren		  => wren,
    q		      => IR_in
    );
    U_REGFILE : entity work.regfile
    port map (
      input    	  => write_data,
      outputA     => A_in,
      outputB     => B_in,
      wren        => regfile_en,
      regASel     => IR_out(25 downto 21),
      regBSel     => IR_out(20 downto 16),
      writeRegSel => write_reg,
      jumpAndLink => jump_link,
      clk         => clk,
      rst         => rst
    );

  end architecture;
