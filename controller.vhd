---- ---- ---- ---- ---- ----
---- ----Controller ---- ----
---- ---- ---- ---- ---- ----
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.library_file.all;

entity controller is
  port (
  clk, rst, toBranchOrNotToBranch                   : in std_logic;
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
        state <= INSTRUCTION_FETCH;
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
        when READ_RAM =>
          next_state <= INSTRUCTION_FETCH;

        -- This state enables the IR to get the value from the memory
        when INSTRUCTION_FETCH =>
          ir_en <= '1';
          mem_en <= '1';
          -- b_sel <= "01";
          next_state <= DECODE;

        -- This state decodes the instruction and determines the appropriate next state
        when DECODE =>
          -- b_sel <= "11";

          if  instruction = OP_LWU or instruction = OP_LH or
              instruction = OP_LW or instruction = OP_SW or
              instruction = OP_LB or instruction = OP_LBU or
              instruction = OP_SB or instruction = OP_LHU or
              instruction = OP_SH then
            next_state <= ENABLE;

          elsif instruction = OP_J or instruction = OP_JR or instruction = OP_JAL then
            next_state <= JUMP;

          else
            next_state <= READ_REG;

          end if;

        when ENABLE =>
          a_en <= '1';
          b_en <= '1';
          next_state <= MEM_ADDR_COMP;

        -- This is where we compute the memory address where we load a word or store a word
        when MEM_ADDR_COMP =>
          a_sel <= "1";
          b_sel <=  IR_IMM;
          alu_sel <= OP_ADDU;
          alu_en <= '1';
          if instruction = OP_LWU or instruction = OP_LH or
             instruction = OP_LW  or instruction = OP_LB or
             instruction = OP_LBU or instruction = OP_LHU then
            next_state <= LW_STATE;
          elsif instruction = OP_SW or instruction = OP_SB or
                instruction = OP_SH then            
            next_state <= SW_STATE;
          end if;

        when READ_REG =>
          a_en <= '1';
          b_en <= '1';
          next_state <= EXECUTION;

        -- This state is entered for R, I, and Branch type instructions
        when EXECUTION =>
          if instruction = OP_ADDIU or instruction = OP_ANDI or
             instruction = OP_ORI or instruction   = OP_XORI or
             instruction = OP_SLTI or instruction  = OP_SLTIU then
                b_sel <=  IR_IMM;
          end if;
          a_sel <= "1";
          alu_en <= '1';
          alu_sel <= instruction;
          if (instruction = OP_BEQ  or instruction = OP_BNE  or
                instruction = OP_BGEZ or instruction = OP_BGTZ or
                instruction = OP_BLTZ or instruction = OP_BLEZ) then
              if toBranchOrNotToBranch = '1' then
                next_state <= BRANCH_TAKEN;
              else
                next_state <= INCREMENT;
              end if;
          else
            next_state <= EXECUTION_1;
          end if;

        -- This state is entered when we have a branch instruction but dont know if we should take the branch yet
        when BRANCH =>
          alu_sel <= instruction;
          if  (instruction = OP_BEQ  and toBranchOrNotToBranch = '1') or
              (instruction = OP_BNE  and toBranchOrNotToBranch = '1') or
              (instruction = OP_BGEZ and toBranchOrNotToBranch = '1') or
              (instruction = OP_BGTZ and toBranchOrNotToBranch = '1') or
              (instruction = OP_BLTZ and toBranchOrNotToBranch = '1') or
              (instruction = OP_BLEZ and toBranchOrNotToBranch = '1') then
                next_state <= BRANCH_TAKEN;
          else
                next_state <= INCREMENT;
          end if;

        -- This state is entered when a branch instruction takes the branch
        when BRANCH_TAKEN =>
          b_sel <= IR_IMM;
          alu_sel <= OP_ADDU;
          pc_write <= '1';
          next_state <= INSTRUCTION_FETCH;

        -- This state is for jump instructions because they are different from branches
        when JUMP =>
          pc_write <= '1';
          pc_sel <= "10";
          next_state <= INSTRUCTION_FETCH;

        -- This state is used to load a word from memory into the reg file
        when LW_STATE =>
          mem_sel <= "1";
          mem_en <= '1';
          next_state <= LW_STATE_1;

        -- Loads a word from memory into the reg file
        when LW_STATE_1 =>
          mem_en <= '1';
          next_state <= LW_STATE_2;

        when LW_STATE_2 =>
          wr_reg_sel <= "1";
          regfile_en <= '1';
          next_state <= INSTRUCTION_FETCH;


        -- This state is used to store a value back into the reg file
        when SW_STATE =>
          mem_en <= '1';
          mem_sel <= "1";
          next_state <= INSTRUCTION_FETCH;

        -- After executing the R type instruction, save it to the registers and increment PC
        when EXECUTION_1 =>
          -- Store the alu output into the reg file
          if instruction = OP_ADDU  or instruction   = OP_SUBU  or
             instruction = OP_MULT  or instruction   = OP_MULTU or
             instruction = OP_AND   or instruction   = OP_OR    or
             instruction = OP_XOR   or instruction   = OP_SRL   or
             instruction = OP_SLL   or instruction   = OP_SRA   or
             instruction = OP_SLT   or instruction   = OP_SLTU  then
            wr_reg_sel <= "1";
          end if;
          regfile_en <= '1';
          -- Simultaneously increment the PC
          alu_sel <= OP_ADDU;
          b_sel <= "01";
          pc_write <= '1';
          next_state <= READ_RAM;

        -- A state that any state may call to increment the PC by one
        when INCREMENT =>
          alu_sel <= OP_ADDU;
          b_sel <= "01";
          pc_write <= '1';
          next_state <= INSTRUCTION_FETCH;
        when others => null;
      end case;
    end process;

  end architecture;
