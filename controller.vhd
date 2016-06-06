---- ---- ---- ---- ---- ----
---- ----Controller ---- ----
---- ---- ---- ---- ---- ----
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.library_file.all;

entity controller is
  port (
  clk, rst, immediate                                        : in std_logic;
  instruction                                                : in opcode;
  alu_sel                                                    : out opcode;
  mem_en, pc_en, a_en, b_en, ir_en, alu_en, wren, regfile_en : out std_logic;
  mem_sel, a_sel, wr_reg_sel, wr_data_sel                    : out std_logic_vector(0 downto 0);
  b_sel, pc_sel                                              : out std_logic_vector(1 downto 0)
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
      alu_sel       <= OP_STALL;
      case( state ) is

        when INIT =>
          next_state <= PC_TO_IR;

        when PC_TO_IR =>
          next_state <= READ_FROM_MEM;

        when READ_FROM_MEM =>
          ir_en <= '1';
          mem_en <= '1';
        --   next_state <= DECODE;
        --
        -- when DECODE =>

          next_state <= REGFILE_TO_AB;

        when REGFILE_TO_AB =>
          a_en <= '1';
          b_en <= '1';
          next_state <= TO_ALU;

        when TO_ALU =>
          a_sel <= "1";
          alu_sel <= instruction;
          if immediate = '1' then
            b_sel <= "10";
          end if;
          alu_en <= '1';
          next_state <= STORE_ALU;

        when STORE_ALU =>
          -- Write ALU output to regfile
          regfile_en <= '1';
          wr_reg_sel <= "1";
          -- At the same time increment the PC
          -- a_sel <= "1";
          alu_sel <= OP_ADDU;
          b_sel <= "01";
          -- if immediate = '0' then
          -- else
            -- b_sel <= "10";
          -- end if;
          pc_en <= '1';
          next_state <= PC_TO_IR;
        when others =>

      end case;
    end process;

  end architecture;
