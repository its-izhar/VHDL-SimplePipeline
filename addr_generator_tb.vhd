-- Izhar Shaikh
-- File: controller_tb.vhd
--
-- Description: Implements a simple testbench for controller.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.config_pkg.all;
use work.user_pkg.all;

entity addr_generator_tb is
end addr_generator_tb;
	   
architecture TB of addr_generator_tb is
    
    constant C_READ_MODE : std_logic := '0';
    constant C_WRITE_MODE : std_logic := '1'; 
	
	constant ADDR_WIDTH	: positive := 15;
	constant TEST_SIZE	: positive := 2**ADDR_WIDTH;
    
	signal clk      : std_logic := '0';
	signal rst      : std_logic;
	
	-- Write Control
	signal wr_en      : std_logic;
	signal wr_addr    : std_logic_vector(ADDR_WIDTH-1 downto 0);

	-- Read Control
	signal rd_addr    : std_logic_vector(ADDR_WIDTH-1 downto 0);

	-- Valid Data I/O
	signal valid_in   : std_logic;
	signal valid_out_ag  : std_logic;

	signal start   	: std_logic := '0';
	signal read_done  	: std_logic	:= '0';
	signal write_done  	: std_logic	:= '0';

	signal size	: std_logic_vector(C_MEM_ADDR_WIDTH downto 0) := (others => '0'); 
	signal clkEn : std_logic := '1';
    
begin

	UUT_AG_READ : entity work.addr_generator(default)
		port map (
			clk	=> clk,
			rst => rst,
			
			mode => C_READ_MODE,
			size => size,
			rd_addr => rd_addr,
			valid_in => valid_in,
			valid_out => valid_out_ag,
       
			-- Control I/O
			start => start,
			done => read_done );

	UUT_AG_WRITE : entity work.addr_generator(default)
		generic map ( ADDR_WIDTH => ADDR_WIDTH )
		port map (
			clk	=> clk,
			rst => rst,
			
			mode => C_WRITE_MODE,
			size => size,
			wr_en => wr_en,
			wr_addr => wr_addr,
			valid_in => valid_out_ag,
			--valid_out => 'X',			
       
			-- Control I/O
			start => start,
			done => write_done );
			
	clk <= not clk and clkEn after 10 ns;

  process
  begin

		-- reset the addr_generator
		rst <= '1';
		start <= '0';
		
		-- Wait for some clk cycles
		for i in 0 to 2 loop
			wait until rising_edge(clk);
		end loop;
		
		rst <= '0';
				
		-- Set Size
		size <= std_logic_vector(to_unsigned( TEST_SIZE, C_MEM_ADDR_WIDTH+1 ));
		
		-- start the operation
		start <= '1';
		wait until rising_edge(clk);
		start <= '0';
		
		for i in 0 to 2 loop
			wait until rising_edge(clk);
		end loop;
		
		-- wait until done
		wait until (read_done = '1' and write_done = '1');

        if (read_done /= '1' or write_done /= '1') then
            report "Done signal not asserted before timeout.";
		else
			report "Success!";
        end if;
		
		wait until rising_edge(clk);
		-- Disable clock
		clkEn <= '0';
		
		wait;
		
  end process;
end TB;
