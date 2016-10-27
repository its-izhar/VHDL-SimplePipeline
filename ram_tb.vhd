-- Izhar Shaikh
-- File: ram_tb.vhd
--
-- Description: Implements a simple testbench for controller.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.config_pkg.all;
use work.user_pkg.all;

entity ram_tb is
end ram_tb;
	   
architecture default of ram_tb is
     
	constant ADDR_WIDTH	: positive := 15;
	constant TEST_SIZE	: positive := 2**ADDR_WIDTH;
    
	signal clk, wen     : std_logic := '0';

	signal waddr, raddr : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
	signal wdata, rdata : std_logic_vector(C_MEM_IN_WIDTH-1 downto 0) := (others => '0');
	
	signal clkEn : std_logic := '1';
    
begin
		
	UUT: entity work.ram
		generic map (
			num_words  => 2**ADDR_WIDTH,
			word_width => C_MEM_IN_WIDTH,
			addr_width => ADDR_WIDTH
			)
		port map (
			clk   => clk,
			-- wr
			wen   => wen,
			waddr => waddr,
			wdata => wdata,
			-- rd
			raddr => raddr,
			rdata => rdata
			);

			
	clk <= not clk and clkEn after 10 ns;

  process    
  begin
	
		wen <= '0';
		wdata <= (others => '0');
		waddr <= (others => '0');
		raddr <= (others => '0');
  
		-- Wait for some clk cycles
		for i in 0 to 2 loop
			wait until rising_edge(clk);
		end loop;
		
		-- write data
		wdata <= std_logic_vector(to_unsigned( TEST_SIZE, C_MEM_IN_WIDTH ));
		waddr <= std_logic_vector(to_unsigned( 33, ADDR_WIDTH ));
		wen <= '1';
		wait until rising_edge(clk);
		wen <= '0';

		wait until rising_edge(clk);
		wdata <= std_logic_vector(to_unsigned( 5238, C_MEM_IN_WIDTH ));
		waddr <= std_logic_vector(to_unsigned( 25, ADDR_WIDTH ));
		wen <= '1';
		wait until rising_edge(clk);
		wen <= '0';
		
		-- Wait for some clk cycles
		for i in 0 to 2 loop
			wait until rising_edge(clk);
		end loop;		
		
		raddr <= std_logic_vector(to_unsigned( 33, ADDR_WIDTH ));
		
		-- Wait for some clk cycles
		for i in 0 to 2 loop
			wait until rising_edge(clk);
		end loop;		

		raddr <= std_logic_vector(to_unsigned( 25, ADDR_WIDTH ));
		
		-- Wait for some clk cycles
		for i in 0 to 2 loop
			wait until rising_edge(clk);
		end loop;		
			
		-- Disable clock
		clkEn <= '0';
		
		wait;
		
  end process;
end default;
