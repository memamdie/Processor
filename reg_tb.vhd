library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.library_file.all;
entity reg_tb is
end entity;
architecture reg_tb of reg_tb is

  signal clk, en       : std_logic := '0';
  signal rst           : std_logic := '1';
  signal input, output : std_logic_vector(31 downto 0);

begin

  UUT : entity work.reg
  port map (
    clk    => clk,
    rst    => rst,
    en     => en,
    input  => input,
    output => output
  );

  input <= x"00221826";
  clk <= not clk after 10 ns;

  process
  begin
      wait for 100 ns;
      rst <= '0';
      wait for 100 ns;
      en <= '1';
      wait for 30 ns;
      en <= '0';
      wait;

  end process;
end architecture;
