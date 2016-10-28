--
-- Author : Izhar Shaikh
--	Reusing the code from previous lab. 
--	
--	File : mult_pipe.vhd
--		This implements a behavioral architecture of a multiplier followed by a register. 
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mult_pipe is
  generic (
    width  :     positive := 8);
  port (
    clk    : in  std_logic;
    rst    : in  std_logic;
    en     : in  std_logic;
    in1    : in  std_logic_vector(width-1 downto 0);
    in2    : in  std_logic_vector(width-1 downto 0);
    output : out std_logic_vector(width*2-1 downto 0));
end mult_pipe;

architecture BHV_MULT_PIPE of mult_pipe is
begin
      process(clk, rst)
          begin
              if(rst='1') then
                  output <= (others => '0');
              elsif (rising_edge(clk)) then              -- Rising clock
                  if(en='1') then                             -- Only update the register on enable
                      output <= std_logic_vector(unsigned(in1) * unsigned(in2));       -- store's the output of register to output
                  end if;
              end if;
        end process;
end BHV_MULT_PIPE;

