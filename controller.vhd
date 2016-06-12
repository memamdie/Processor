---- ---- ---- ---- ---- ----
---- ----Controller ---- ----
---- ---- ---- ---- ---- ----
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.library_file.all;

entity controller is
  port (
  clk, rst, immediate                               : in std_logic;
  instruction                                       : in opcode;
  alu_sel                                           : out opcode;
  mem_en, pc_write, a_en, b_en, ir_en               : out std_logic;
  alu_en, wren, regfile_en, pc_write_cond, alu_zero : out std_logic;
  mem_sel, a_sel, wr_reg_sel, wr_data_sel           : out std_logic_vector(0 downto 0);
  b_sel, pc_sel                                     : out std_logic_vector(1 downto 0)
  );
end entity;

architecture arch of controller is
  signal state, next_state : STATE_TYPE;
  begin
    sequential : process(clk, rst)
    begin
      if rst = '1' then
        state <= INIT;
      elsif rising_edge(clk) then
        state <= next_state;
      end if;
    end process;

    states : process(instruction, state)
    begin
      mem_en        <= '0';
      pc_write      <= '0';
      a_en          <= '0';
      b_en          <= '0';
      ir_en         <= '0';
      alu_en        <= '0';
      wren          <= '0';
      regfile_en    <= '0';
      alu_zero      <= '0';
      pc_write_cond <= '0';
      mem_sel       <= (others => '0');
      a_sel         <= (others => '0');
      wr_reg_sel    <= (others => '0');
      wr_data_sel   <= (others => '0');
      b_sel         <= (others => '0');
      pc_sel        <= (others => '0');
      alu_sel       <= OP_STALL;
      case( state ) is

        when INIT =>
          ir_en <= '1';
          -- pc_write <= '1';
          b_sel <= "01";

          next_state <= FETCH;

        when FETCH =>
          b_sel <= "11";

          if  instruction = OP_LWU or instruction = OP_LH or
              instruction = OP_LW or instruction = OP_SW or
              instruction = OP_LB or instruction = OP_LBU or
              instruction = OP_SB or instruction = OP_LHU or
              instruction = OP_SH then
            next_state <= MEM_ADDR_COMP;

          elsif instruction = OP_ADDU or instruction = OP_SUBU or
                instruction = OP_MULT or instruction = OP_MULTU or
                instruction = OP_AND or instruction = OP_OR or
                instruction = OP_XOR or instruction = OP_SRL or
                instruction = OP_SLL or instruction = OP_SRA or
                instruction = OP_SLT or instruction = OP_SLTU then
            next_state <= EXECUTION;

          elsif instruction = OP_BEQ or instruction = OP_BGTZ or
          instruction = OP_BGEZ or instruction = OP_BNE or
          instruction = OP_BLTZ or instruction = OP_BLEZ then
            next_state <= BRANCH;

          elsif instruction = OP_J or instruction = OP_JR or instruction = OP_JAL then
            next_state <= JUMP;
          end if;

        when MEM_ADDR_COMP =>
          a_sel <= "1";
          b_sel <= "10";
          if instruction = OP_LW then
            next_state <= LW_STATE;
          elsif instruction = OP_SW then
            next_state <= SW_STATE;
          end if;

        when EXECUTION =>
          a_sel <= "1";
          alu_sel <= instruction;
          next_state <= EXECUTION_1;

        when BRANCH =>
          a_sel <= "1";
          pc_sel <= "01";
          pc_write <= '1';
          next_state <= INIT;

        when JUMP =>
          pc_write <= '1';
          pc_sel <= "10";
          next_state <= INIT;

        when LW_STATE =>
          mem_sel <= "1";
          next_state <= LW_STATE_1;

        when LW_STATE_1 =>
          wr_reg_sel <= "1";
          regfile_en <= '1';
          next_state <= INIT;

        when SW_STATE =>
          mem_en <= '1';
          mem_sel <= "1";
          next_state <= INIT;

        when EXECUTION_1 =>
          wr_reg_sel <= "1";
          regfile_en <= '1';
          alu_sel <= OP_ADDU;
          b_sel <= "01";
          pc_write <= '1';

          next_state <= INIT;

        when others => null;
      end case;
    end process;

  end architecture;
