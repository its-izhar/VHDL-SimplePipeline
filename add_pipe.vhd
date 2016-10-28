--
-- Author : Izhar Shaikh
--	Reusing the code from previous lab. 
--	
--	File : add_pipe.vhd
--		This implements a behavioral architecture of an adder followed by a register. 
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity add_pipe is
  generic (
    width  :     positive := 16);
  port (
    clk    : in  std_logic;
    rst    : in  std_logic;
    en     : in  std_logic;
    in1    : in  std_logic_vector(width-1 downto 0);
    in2    : in  std_logic_vector(width-1 downto 0);
    output : out std_logic_vector(width downto 0));
end add_pipe;

architecture BHV_ADD_PIPE of add_pipe is
begin
  process(clk, rst)
        variable temp : unsigned(width downto 0);       -- temp to store the adder output
    begin
        if(rst='1') then
            output <= (others => '0');
        elsif (rising_edge(clk)) then              -- Rising clock
            if(en='1') then                             -- Only update the register on enable
                temp := resize(unsigned(in1), width+1) + resize(unsigned(in2), width+1);
                output <= std_logic_vector(temp);       -- store's the output of register to output
            end if;
        end if;
  end process;
end BHV_ADD_PIPE;

