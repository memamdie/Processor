library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.library_file.all;

entity top_level_tb is
end entity;

architecture TB of top_level_tb is

  signal clk, go                : std_logic := '0';
  signal rst                    : std_logic := '1';
  signal switches               : std_logic_vector(7 downto 0);
  signal buttons                : std_logic_vector(1 downto 0);
  signal led0, led1, led2, led3 : std_logic_vector(6 downto 0);
begin

    UUT : entity work.top_level
        port map (
            clk        => clk,
            rst        => rst,
            go         => go,
            switch     => switches,
            button     => buttons,
            led0       => led0,
            led1       => led1,
            led2       => led2,
            led3       => led3
        );

      clk <= not clk after 10 ns;
      process
      begin
          switches <= (others => '0');
          buttons <= (others => '0');
          wait for 30 ns;
          rst <= '0';
          -- wait for 50 ns;
          -- buttons <= "01";
          -- switches <= x"22";
          -- wait for 50 ns;
          -- buttons <= "10";
          -- switches <= x"44";
          -- wait for 100 ns;
          -- go <= '1';
          wait for 40000 ns;
          -- rst <= '0';
          -- wait for 50 ns;
          -- rst <= '1';
          -- wait for 40500 ns;
          -- rst <= '0';
          -- wait for 50 ns;
          -- rst <= '1';
          -- wait for 4050 ns;
          wait;

          report "DONE!!!!!!" severity note;
      end process;
end architecture;
