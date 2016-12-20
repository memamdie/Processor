library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity regFile is
  generic (width  :     positive := 32);
  port(
    input 	    : in std_logic_vector(width-1 downto 0);
    wren        : in std_logic;
    regASel     : in std_logic_vector(4 downto 0);
    regBSel     : in std_logic_vector(4 downto 0);
    writeRegSel : in std_logic_vector(4 downto 0);
    jumpAndLink : in std_logic;
    clk,rst     : in std_logic;
    outputA     : out std_logic_vector(width-1 downto 0);
    outputB     : out std_logic_vector(width-1 downto 0)
  );

end regFile;

architecture BHV of regFile is
  type registerFile is array(natural range <>) of std_logic_vector (width-1 downto 0);
  signal registers: registerFile(31 downto 0);
  begin

    regFile : process(clk,rst)
    begin

      -- when reset all the ouputs set to zero
      if (rst = '1') then
        outputA   <= (others => '0');
        outputB   <= (others => '0');

        -- when reset all the registers set to zero
        for i in 0 to 31 loop
          registers(i) <= (others =>'0');
        end loop;

      elsif rising_edge(clk) then
        registers(0) <= (others =>'0'); -- $s0 will be always set to zero
        outputA <= registers(to_integer(unsigned(regAsel)));
        outputB <= registers(to_integer(unsigned(regBsel)));

        if wren ='1' then

          if jumpAndLink = '1' then -- when jump and link we write to register $s31
          registers(31) <= input;
        else
          registers(to_integer(unsigned(writeRegSel)))<=input;
        end if;

        if (regAsel = writeRegSel) then
          outputA <= input;
        end if;

        if (regBsel = writeRegSel) then
          outputB <= input;
        end if;

      end if ;
    end if;
  end process;

end BHV;
