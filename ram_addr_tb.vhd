-- Izhar Shaikh
-- File: ram_addr_tb.vhd
--
-- Description: Implements a simple testbench for controller.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.config_pkg.all;
use work.user_pkg.all;

entity ram_addr_tb is
end ram_addr_tb;
	   
architecture default of ram_addr_tb is
     
	constant ADDR_WIDTH	: positive := 15;
	constant TEST_SIZE	: positive := 2**ADDR_WIDTH;
    
	signal clk, wen, rst, mode, valid_out, start, read_done, pipeline_valid_out     : std_logic := '0';

	signal waddr, raddr : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
	signal wdata, rdata : std_logic_vector(C_MEM_IN_WIDTH-1 downto 0) := (others => '0');
	
	signal pipeline_data_out : std_logic_vector(C_MEM_OUT_WIDTH-1 downto 0) := (others => '0');
	
	signal size : std_logic_vector(ADDR_WIDTH downto 0) := (others => '0');
	
	signal clkEn : std_logic := '1';
    
begin

	UUT_AG_READ : entity work.addr_generator(default)
		port map (
			clk	=> clk,
			rst => rst,
			
			mode => '0',
			size => size,
			rd_addr => raddr,
			valid_in => '0',
			valid_out => valid_out,
       
			-- Control I/O
			start => start,
			done => read_done );
		
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

    U_PIPELINE : entity work.datapath(default)
        generic map (
            data_width_in  => C_MEM_IN_WIDTH,
            data_width_out => C_MEM_OUT_WIDTH )
        port map (
            pipe_clk   => clk,
            pipe_rst   => rst,
            pipe_en    => '1',
            valid_in(0)   => valid_out,
            valid_out(0) => pipeline_valid_out,
            pipe_data_in    => rdata,
            pipe_data_out   => pipeline_data_out);			
			
	clk <= not clk and clkEn after 10 ns;

  process   
	variable count : integer := 0;
  begin
		rst <= '1';	
		start <= '0';
		wen <= '0';
		wdata <= (others => '0');
		waddr <= (others => '0');
		-- Set Size
		size <= std_logic_vector(to_unsigned( TEST_SIZE, ADDR_WIDTH+1 ));
  
		-- Wait for some clk cycles
		for i in 0 to 2 loop
			wait until rising_edge(clk);
		end loop;
		
		rst <= '0';
		
		wait until rising_edge(clk);
		
		-- write data
		wdata <= std_logic_vector(to_unsigned( 786, C_MEM_IN_WIDTH ));
		waddr <= std_logic_vector(to_unsigned( 1, ADDR_WIDTH ));
		wen <= '1';
		wait until rising_edge(clk);
		wen <= '0';

		wait until rising_edge(clk);
		wdata <= std_logic_vector(to_unsigned( 5238, C_MEM_IN_WIDTH ));
		waddr <= std_logic_vector(to_unsigned( 2, ADDR_WIDTH ));
		wen <= '1';
		wait until rising_edge(clk);
		wen <= '0';
		
		-- Wait for some clk cycles
		for i in 0 to 2 loop
			wait until rising_edge(clk);
		end loop;		
		
		-- start the operation
		start <= '1';
		wait until rising_edge(clk);
		start <= '0';
		
		for i in 0 to 2 loop
			wait until rising_edge(clk);
		end loop;
		
		-- wait until done
		wait until (read_done = '1');

        if (read_done /= '1') then
            report "Done signal not asserted before timeout.";
		else
			report "Success!";
        end if;
		
		wait until rising_edge(clk);

		for i in 0 to 2 loop
			wait until rising_edge(clk);
		end loop;
		
		-- Disable clock
		clkEn <= '0';
		
		wait;
		
  end process;
end default;
