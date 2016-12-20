---- ---- ---- ---- ---- ----
---- ----Controller ---- ----
---- ---- ---- ---- ---- ----
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.library_file.all;

entity controller is
  generic(width : positive := 32);
  port (
    clk, rst, toBranchOrNotToBranch                : in std_logic;
    IR_out, program_counter                        : in std_logic_vector(width-1 downto 0);
    alu_sel                                        : out opcode;
    mem_en, pc_write, a_en, b_en, ir_en, jump_link : out std_logic;
    alu_en, wren, regfile_en, alu_mult_reg_en      : out std_logic;
    pc_write_cond, alu_zero                        : out std_logic;
    mem_sel, wr_reg_sel                            : out std_logic_vector(0 downto 0);
    a_sel, b_sel, pc_sel, wr_data_sel              : out std_logic_vector(1 downto 0)
  );
end entity;

architecture arch of controller is
  signal state, next_state : STATE_TYPE;
  signal instruction_signal : opcode;
  begin
    sequential : process(clk, rst)
    begin
      if rst = '1' then
        state <= FETCH;
      elsif rising_edge(clk) then
        state <= next_state;
      end if;
    end process;

    states : process(IR_out, state, instruction_signal, toBranchOrNotToBranch)
    variable instruction : opcode;

    begin
      mem_en          <= '0';
      jump_link       <= '0';
      pc_write        <= '0';
      a_en            <= '0';
      b_en            <= '0';
      ir_en           <= '0';
      alu_en          <= '0';
      alu_mult_reg_en <= '0';

      wren            <= '0';
      regfile_en      <= '0';
      alu_zero        <= '0';
      pc_write_cond   <= '0';
      mem_sel         <= (others => '0');
      a_sel           <= (others => '0');
      wr_reg_sel      <= (others => '0');
      wr_data_sel     <= (others => '0');
      b_sel           <= (others => '0');
      pc_sel          <= (others => '0');
      alu_sel         <= OP_STALL;
      instruction     := OP_STALL;

      case( state ) is

        when INCREMENT =>
          b_sel <= B_MUX_FOUR;
          pc_write <= '1';
          alu_sel <= OP_ADDU;
          next_state <= READ_PC;

        when READ_PC  =>
          next_state <= FETCH;

        when FETCH =>
            ir_en <= '1';
            mem_en <= '1';
            next_state <= DECODE;

        when DECODE =>
            instruction := OP_STALL;
            if IR_out(31 downto 26) = "000000" then
              case( IR_out(5 downto 0) ) is
                when CONST_ADDU =>
                  instruction := OP_ADDU;
                when CONST_AND =>
                  instruction := OP_AND;
                when CONST_JR =>
                  instruction := OP_JR;
                when CONST_MFHI =>
                  instruction := OP_MFHI;
                when CONST_MFLO =>
                  instruction := OP_MFLO;
                when CONST_MULT =>
                  instruction := OP_MULT;
                when CONST_MULTU =>
                  instruction := OP_MULTU;
                when CONST_OR =>
                  instruction := OP_OR;
                when CONST_SLT =>
                  instruction := OP_SLT;
                when CONST_SLTU =>
                  instruction := OP_SLTU;
                when CONST_SRA =>
                  instruction := OP_SRA;
                when CONST_SRL =>
                  instruction := OP_SRL;
                when CONST_SUBU =>
                  instruction := OP_SUBU;
                when CONST_XOR =>
                  instruction := OP_XOR;
                when CONST_SLL =>
                  if program_counter /= x"00000000" then
                    instruction := OP_SLL;
                  end if;
                when others =>
                  instruction := OP_STALL;
              end case;

            elsif IR_out(31 downto 26) = "000001"  then
              case( IR_out(20 downto 16) ) is
                when CONST_BLTZ =>
                  instruction := OP_BLTZ;
                when CONST_BGEZ =>
                  instruction := OP_BGEZ;
                when others =>
                  instruction := OP_STALL;
              end case;

            else
              case( IR_out(31 downto 26) ) is
                when CONST_ADDIU =>
                  instruction := OP_ADDIU;
                when CONST_SUBIU =>
                  instruction := OP_SUBIU;
                when CONST_ANDI =>
                  instruction := OP_ANDI;
                when CONST_J =>
                  instruction := OP_J;
                when CONST_BEQ =>
                  instruction := OP_BEQ;
                when CONST_BGTZ =>
                  instruction := OP_BGTZ;
                when CONST_BLEZ =>
                  instruction := OP_BLEZ;
                when CONST_BNE =>
                  instruction := OP_BNE;
                when CONST_LB =>
                  instruction := OP_LB;
                when CONST_LBU =>
                  instruction := OP_LBU;
                when CONST_LH =>
                  instruction := OP_LH;
                when CONST_LW =>
                  instruction := OP_LW;
                when CONST_LWU =>
                  instruction := OP_LWU;
                when CONST_ORI =>
                  instruction := OP_ORI;
                when CONST_SB =>
                  instruction := OP_SB;
                when CONST_SLTI =>
                  instruction := OP_SLTI;
                when CONST_SLTIU =>
                  instruction := OP_SLTIU;
                when CONST_SW =>
                  instruction := OP_SW;
                when CONST_XORI =>
                  instruction := OP_XORI;
                when others =>
                  instruction := OP_STALL;
              end case;
            end if;
            instruction_signal <= instruction;
            -- Memory instructions
            if  instruction = OP_LWU or instruction = OP_LH or
              instruction = OP_LW or instruction = OP_SW or
              instruction = OP_LB or instruction = OP_LBU or
              instruction = OP_SB or instruction = OP_LHU or
              instruction = OP_SH then
                next_state <= READ_REGFILE;

            -- Jump completion
            elsif instruction = OP_J or instruction = OP_JR or instruction = OP_JAL then
              next_state <= JUMP;

            -- R type instructions
          elsif instruction = OP_MFHI or instruction = OP_MFLO then
              next_state <= EXECUTION_2;
            else
              next_state <= EXECUTION;

          end if;

        when READ_REGFILE =>
          a_en <= '1';
          next_state <= MEM_ADDR_COMP;

        when MEM_ADDR_COMP =>
          a_sel            <= A_MUX_A_REG;
          b_sel            <= B_MUX_SIGN_EXT;
          alu_sel          <= OP_ADDU;
          alu_en           <= '1';
          if  instruction_signal = OP_LWU or instruction_signal = OP_LH or
            instruction_signal = OP_LW  or instruction_signal = OP_LB or
            instruction_signal = OP_LBU or instruction_signal = OP_LHU then
              next_state   <= READ_MEM;
          else
              next_state   <= STORE_MEM;
          end if;

        when READ_MEM      =>
            mem_sel       <= "1";
            next_state    <= LOAD_MEM;
        when LOAD_MEM      =>
            mem_en        <= '1';
            next_state    <= WRITE_BACK;

        when STORE_MEM    =>
            mem_sel       <= "1";
            mem_en        <= '1';
            next_state    <= INCREMENT;

        when WRITE_BACK   =>
            regfile_en    <= '1';
            wr_data_sel   <= WR_DATA_MUX_MEM;
            next_state    <= INCREMENT;

        when EXECUTION    =>
            a_en          <= '1';
            b_en          <= '1';
            next_state    <= EXECUTION_1;
        when EXECUTION_1  =>
            a_sel         <= A_MUX_A_REG;
            if instruction_signal = OP_ADDIU or
               instruction_signal = OP_SUBIU or
               instruction_signal = OP_ANDI  or
               instruction_signal = OP_ORI   or
               instruction_signal = OP_XORI  or
               instruction_signal = OP_SLTI  or
               instruction_signal = OP_SLTIU then
                  b_sel   <= B_MUX_SIGN_EXT;
            elsif instruction_signal = OP_SRL or
                  instruction_signal = OP_SRA or
                  instruction_signal = OP_SLL then
                  a_sel   <= A_MUX_SHIFT;
            end if;
            alu_sel       <= instruction_signal;
            alu_en        <= '1';
            if instruction_signal = OP_MULT or instruction_signal = OP_MULTU then
              alu_mult_reg_en <= '1';
              next_state  <= INCREMENT;
            --Branch completion
            elsif instruction_signal = OP_BEQ  or instruction_signal = OP_BNE
              or instruction_signal  = OP_BLEZ or instruction_signal = OP_BGTZ
              or instruction_signal  = OP_BLTZ or instruction_signal = OP_BGEZ then
                if toBranchOrNotToBranch = '1' then
                  next_state <= BRANCH;
                else
                  next_state <= INCREMENT;
                end if;
            else
              next_state  <= EXECUTION_2;
            end if;

        when EXECUTION_2  =>
          wr_reg_sel    <= "1";
          if instruction_signal = OP_ADDIU or
             instruction_signal = OP_SUBIU or
             instruction_signal = OP_ANDI  or
             instruction_signal = OP_XORI  or
             instruction_signal = OP_ORI   or
             instruction_signal = OP_SLTI  or
             instruction_signal = OP_SLTIU then
                wr_reg_sel  <= "0";
          elsif instruction_signal = OP_MFHI then
                wr_data_sel <= WR_DATA_MUX_MFHI;
          elsif instruction_signal = OP_MFLO then
                wr_data_sel <= WR_DATA_MUX_MFLO;
            end if;
            regfile_en    <= '1';
            next_state    <= INCREMENT;

        when BRANCH       =>
            a_sel         <= A_MUX_PC_REG;
            b_sel         <= B_MUX_SEXT_SHFL;
            alu_sel       <= OP_ADDU;
            alu_en        <= '1';
            pc_write      <= '1';
            pc_sel        <= PC_MUX_ALU;
            next_state    <= READ_PC;

        when JUMP         =>
            pc_write      <= '1';
            pc_sel        <= PC_MUX_IR;
            next_state    <= FETCH;
        when others       => null;
      end case;
    end process;
  end architecture;
