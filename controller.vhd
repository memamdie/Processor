---- ---- ---- ---- ---- ----
---- ----Controller ---- ----
---- ---- ---- ---- ---- ----
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.library_file.all;

entity controller is
  port (
  clk, rst, eq, gt, lt                              : in std_logic;
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
      a_en          <= '1';
      b_en          <= '1';
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

        -- This allows the PC to increment and a new value to be read from memory
        when STALL =>
          next_state <= INIT;

        -- This state enables the IR to get the value from the memory
        when INIT =>
          ir_en <= '1';
          mem_en <= '1';
          b_sel <= "01";
          next_state <= FETCH;

        -- This state decodes the instruction and determines the appropriate next state
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

        -- This is where we compute the memory address where we load a word or store a word
        when MEM_ADDR_COMP =>
          a_sel <= "1";
          b_sel <= "10";
          if instruction = OP_LW then
            next_state <= LW_STATE;
          elsif instruction = OP_SW then
            next_state <= SW_STATE;
          end if;

        -- This state is entered for R type instructions
        when EXECUTION =>
          a_sel <= "1";
          alu_sel <= instruction;
          next_state <= EXECUTION_1;

        -- This state is entered when we have a branch instruction but dont know if we should take the branch yet
        when BRANCH =>
          alu_sel <= instruction;
          if (instruction = OP_BEQ and eq = '1') or
          (instruction = OP_BNE and eq = '0') or
          (instruction = OP_BGEZ and gt = '1') or
          (instruction = OP_BGTZ and gt = '1') or
          (instruction = OP_BLTZ and lt = '1') or
          (instruction = OP_BLEZ and lt = '1') then
            next_state <= BRANCH_TAKEN;
          else
            next_state <= INCREMENT;
          end if;

        -- This state is entered when a branch instruction takes the branch
        when BRANCH_TAKEN =>
          b_sel <="10";
          alu_sel <= OP_ADDU;
          pc_write <= '1';
          next_state <= INIT;

        -- This state is for jump instructions because they are different from branches
        when JUMP =>
          pc_write <= '1';
          pc_sel <= "10";
          next_state <= INIT;

        -- This state is used to load a word from memory into the reg file
        when LW_STATE =>
          mem_sel <= "1";
          next_state <= LW_STATE_1;

        -- Loads a word from memory into the reg file
        when LW_STATE_1 =>
          wr_reg_sel <= "1";
          regfile_en <= '1';
          next_state <= INIT;


        -- This state is used to store a value back into the reg file
        when SW_STATE =>
          mem_en <= '1';
          mem_sel <= "1";
          next_state <= INIT;

        -- After executing the R type instruction, save it to the registers and increment PC
        when EXECUTION_1 =>
          wr_reg_sel <= "1";
          regfile_en <= '1';
          alu_sel <= OP_ADDU;
          b_sel <= "01";
          pc_write <= '1';
          next_state <= STALL;

        -- A state that any state may call to increment the PC by one
        when INCREMENT =>
          alu_sel <= OP_ADDU;
          b_sel <= "01";
          pc_write <= '1';
          next_state <= INIT;
        when others => null;
      end case;
    end process;

  end architecture;
