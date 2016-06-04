---- ---- ---- ---- ---- ----
---- ----Controller ---- ----
---- ---- ---- ---- ---- ----
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.library_file.all;

entity controller is
  port (
    clk, rst                                                   : in std_logic;
    IR                                                         : in std_logic_vector(5 downto 0);
    mem_en, pc_en, a_en, b_en, ir_en, alu_en, wren, regfile_en : out std_logic;
    mem_sel, a_sel, wr_reg_sel, wr_data_sel                    : out std_logic_vector(0 downto 0);
    b_sel, pc_sel                                              : out std_logic_vector(1 downto 0);
    ALU_op                                                     : out opcode
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

  states : process(IR, state)
  begin
    mem_en        <= '0';
    pc_en         <= '0';
    a_en          <= '0';
    b_en          <= '0';
    ir_en         <= '0';
    alu_en        <= '0';
    wren          <= '0';
    regfile_en    <= '0';
    mem_sel       <= (others => '0');
    a_sel         <= (others => '0');
    wr_reg_sel    <= (others => '0');
    wr_data_sel   <= (others => '0');
    b_sel         <= (others => '0');
    pc_sel        <= (others => '0');
    ALU_op        <= ALU_STALL;

    case( state ) is

      when INIT =>
        next_state <= PC_TO_ADDR;

      when PC_TO_ADDR =>
        ir_en <= '1';
        mem_en <= '1';
        next_state <= DECODE;

      when DECODE =>
        if  IR = OP_ADDU or IR = OP_AND or IR = OP_JR or
            IR = OP_MFHI or IR = OP_MFLO or IR = OP_MULT or
            IR = OP_MULTU or IR = OP_OR or IR = OP_SLL or
            IR = OP_SLT or IR = OP_SLTU or IR = OP_SRA or
            IR = OP_SRL or IR = OP_SUBU or IR = OP_XOR then

          wr_reg_sel <= "1";
          next_state <= REGFILE_TO_AB;
          
        end if;

      when REGFILE_TO_AB =>
        a_en <= '1';
        b_en <= '1';
        next_state <= TO_ALU;

      when TO_ALU =>
          if IR = OP_ADDU then
            ALU_op <= ALU_ADDU;
          elsif IR = OP_JR then
            ALU_op <= ALU_JR;
          elsif IR = OP_MFHI then
            ALU_op <= ALU_MFHI;
          elsif IR = OP_MFLO then
            ALU_op <= ALU_MFLO;
          elsif IR = OP_MULT then
            ALU_op <= ALU_MULT;
          elsif IR = OP_MULTU then
            ALU_op <= ALU_MULTU;
          elsif IR = OP_OR then
            ALU_op <= ALU_OR;
          elsif IR = OP_SLL then
            ALU_op <= ALU_SLL;
          elsif IR = OP_SLT then
            ALU_op <= ALU_SLT;
          elsif IR = OP_SLTU then
            ALU_op <= ALU_SLTU;
          elsif IR = OP_SRA then
            ALU_op <= ALU_SRA;
          elsif IR = OP_SRL then
            ALU_op <= ALU_SRL;
          elsif IR = OP_SRL then
            ALU_op <= ALU_SRL;
          elsif IR = OP_SUBU then
            ALU_op <= ALU_SUBU;
          elsif IR = OP_XOR then
            ALU_op <= ALU_XOR;
          end if;

          a_sel <= "1";
          alu_en <= '1';
          next_state <= STORE_ALU;

      when STORE_ALU =>
          regfile_en <= '1';
          wr_reg_sel <= "1";
          -- a_sel <= "1";
          b_sel <= "01";
          ALU_op <= ALU_ADDU;
          pc_en <= '1';
          next_state <= PC_TO_ADDR;
      when others =>

    end case;
  end process;

end architecture;
