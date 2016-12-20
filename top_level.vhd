library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.library_file.all;
entity top_level is
  port (
      clk, rst, go                : in std_logic;
      switch                      : in std_logic_vector(7 downto 0);
      button                      : in std_logic_vector(1 downto 0);
      led0, led1, led2, led3      : out std_logic_vector(6 downto 0)
  );
end entity;

architecture top_level of top_level is
  signal alu_sel                                                   : opcode;
  signal mem_en, pc_write, a_en, b_en, alu_mult_reg_en             : std_logic;
  signal ir_en, alu_en, wren, regfile_en                           : std_logic;
  signal pc_write_cond, alu_zero, toBranchOrNotToBranch, jump_link : std_logic;
  signal mem_sel, wr_reg_sel                                       : std_logic_vector(0 downto 0);
  signal a_sel, b_sel, pc_sel, wr_data_sel                         : std_logic_vector(1 downto 0);
  signal IR, PC                                                    : std_logic_vector(31 downto 0);
begin
  U_CONTROLLER : entity work.controller
  port map (
      clk                   => clk,
      rst                   => rst,
      IR_out                => IR,
      program_counter       => PC,
      toBranchOrNotToBranch => toBranchOrNotToBranch,
      jump_link             => jump_link,
      mem_en                => mem_en,
      pc_write              => pc_write,
      pc_write_cond         => pc_write_cond,
      alu_zero              => alu_zero,
      a_en                  => a_en,
      b_en                  => b_en,
      ir_en                 => ir_en,
      alu_en                => alu_en,
      alu_mult_reg_en       => alu_mult_reg_en,
      wren                  => wren,
      regfile_en            => regfile_en,
      mem_sel               => mem_sel,
      a_sel                 => a_sel,
      wr_reg_sel            => wr_reg_sel,
      wr_data_sel           => wr_data_sel,
      b_sel                 => b_sel,
      alu_sel               => alu_sel,
      pc_sel                => pc_sel
  );
  U_DATAPATH : entity work.datapath
  port map (
      clk                   => clk,
      rst                   => rst,
      instruction           => IR,
      program_counter       => PC,
      toBranchOrNotToBranch => toBranchOrNotToBranch,
      jump_link             => jump_link,
      mem_en                => mem_en,
      pc_write              => pc_write,
      pc_write_cond         => pc_write_cond,
      alu_zero              => alu_zero,
      a_en                  => a_en,
      b_en                  => b_en,
      alu_mult_reg_en       => alu_mult_reg_en,
      ir_en                 => ir_en,
      alu_en                => alu_en,
      wren                  => wren,
      regfile_en            => regfile_en,
      mem_sel               => mem_sel,
      a_sel                 => a_sel,
      wr_reg_sel            => wr_reg_sel,
      wr_data_sel           => wr_data_sel,
      b_sel                 => b_sel,
      alu_sel               => alu_sel,
      pc_sel                => pc_sel
  );
end architecture;
