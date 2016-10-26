-- Izhar Shaikh
-- File: controller_tb.vhd
--
-- Description: Implements a simple testbench for controller.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.config_pkg.all;
use work.user_pkg.all;

entity controller_tb is
end controller_tb;
	   
architecture default of controller_tb is

	component controller

	  port(clk      : in std_logic;
		   rst      : in std_logic;
		   
		   -- Mode control out for address generators
		   ip_addr_gen_mode_out 	: out std_logic;     -- 0: Read Mode, 1: Write Mode
		   op_addr_gen_mode_out		: out std_logic;
		   
		   -- Size of memory (i.e. The number of addressess to be generated by Address Generator)
		   ip_addr_gen_size_out 	: out std_logic_vector(C_MEM_ADDR_WIDTH downto 0);
		   op_addr_gen_size_out 	: out std_logic_vector(C_MEM_ADDR_WIDTH downto 0);   
			   
		   -- Address Generators Control I/O
		   ip_addr_gen_go	    : out std_logic;
		   op_addr_gen_go	    : out std_logic;
		   ip_addr_gen_done		: in std_logic;
		   op_addr_gen_done		: in std_logic;

		   -- Controller Control I/O
		   go    	: in std_logic;
		   done  	: out std_logic;

		   -- Size in for controller
		   size		: in std_logic_vector(C_MEM_ADDR_WIDTH downto 0));   
		   
	end component;

      
    constant C_READ_MODE : std_logic := '0';
    constant C_WRITE_MODE : std_logic := '1'; 
	
	constant ADDR_WIDTH	: positive := 15;
	constant TEST_SIZE	: positive := 2**ADDR_WIDTH;
    
	signal clk      : std_logic := '0';
	signal rst      : std_logic;
	
	signal ip_addr_gen_mode_out 	: std_logic;     -- 0: Read Mode, 1: Write Mode
	signal op_addr_gen_mode_out	: std_logic;
	
	signal ip_addr_gen_size_out 	: std_logic_vector(C_MEM_ADDR_WIDTH downto 0);
	signal op_addr_gen_size_out 	: std_logic_vector(C_MEM_ADDR_WIDTH downto 0);   

	signal ip_addr_gen_go	    : std_logic;
	signal op_addr_gen_go	    : std_logic;

	signal ip_addr_gen_done	: std_logic	:= '0';
	signal op_addr_gen_done	: std_logic	:= '0';

	signal go    	: std_logic;
	signal done  	: std_logic	:= '0';

	signal size	: std_logic_vector(C_MEM_ADDR_WIDTH downto 0) := (others => '0');  
	signal clkEn : std_logic := '1';
    
begin

	UUT : entity work.controller
		port map (
			clk	=> clk,
			rst => rst,
       
			-- Mode control out for address generators
			ip_addr_gen_mode_out => ip_addr_gen_mode_out,
			op_addr_gen_mode_out => op_addr_gen_mode_out,

			-- Size of memory (i.e. The number of addressess to be generated by Address Generator)
			ip_addr_gen_size_out => ip_addr_gen_size_out,
			op_addr_gen_size_out => op_addr_gen_size_out,
			   
			-- Address Generators Control I/O
			ip_addr_gen_go => ip_addr_gen_go,
			op_addr_gen_go => op_addr_gen_go,
			ip_addr_gen_done => ip_addr_gen_done,
			op_addr_gen_done => op_addr_gen_done,

			-- Controller Control I/O
			go => go,
			done => done,

			-- Size in for controller
			size => size );
			
	clk <= not clk and clkEn after 10 ns;

  process    
  begin

		-- reset the controller
		rst <= '1';
		go <= '0';
		
		-- Wait for some clk cycles
		for i in 0 to 2 loop
			wait until rising_edge(clk);
		end loop;
		
		rst <= '0';
		
		-- Set Size
		size <= std_logic_vector(to_unsigned( TEST_SIZE, C_MEM_ADDR_WIDTH+1 ));
		
		-- start the operation
		go <= '1';
		wait until rising_edge(clk);
		go <= '0';
		
		-- wait for random amount of time
		-- assume that address generator is working during this time
		for i in 0 to 10 loop
			wait until rising_edge(clk);
		end loop;				
		
		-- address generators finished
		-- assuming that both address generators finish at different time instants..
		ip_addr_gen_done <= '1';
		for i in 0 to 2 loop
		wait until rising_edge(clk);
		end loop;		
		op_addr_gen_done <= '1';
		
		for i in 0 to 2 loop
		wait until rising_edge(clk);
		end loop;
		
		if(done = '1') then
			report "Success!";
		end if;
		
		-- Disable clock
		clkEn <= '0';
		
		wait;
		
  end process;
end default;
