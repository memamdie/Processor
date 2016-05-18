---- ---- ---- ---- ---- ----
---- ----Controller ---- ----
---- ---- ---- ---- ---- ----
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.library_file.all;
entity controller is
  port (
    IR                                      : in std_logic_vector(15 downto 0);
    mem_sel, a_sel, wr_reg_sel, wr_data_sel : out std_logic_vector(0 downto 0);
    b_sel, pc_sel                           : out std_logic_vector(1 downto 0);
    ALU_op                                  : out opcode
  );
end entity;

architecture arch of controller is



begin



end architecture;
