library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pipe_tb is
end pipe_tb;

architecture TB of pipe_tb is

    constant data_width_in  : positive := 32 ;
    constant data_width_out : positive := 17 ;

	signal pipe_clk : std_logic := '0';
	signal pipe_rst : std_logic := '0';

	-- Enable for registers in each level of the pipeline
	signal pipe_en	: std_logic := '0';
	
	-- I/O interface
	signal pipe_data_in   : std_logic_vector(data_width_in-1 downto 0)	:=	(others => '0');
	signal pipe_data_out  : std_logic_vector(data_width_out-1 downto 0)	:=	(others => '0');
	
	signal valid_in        : std_logic	:= '0';
	signal valid_out       : std_logic	:= '0';
	
	signal clkEn  : std_logic := '1';

begin

    UUT : entity work.datapath(default)
		generic map (
			data_width_in  => data_width_in,
			data_width_out  => data_width_out)
        port map (
			pipe_clk => pipe_clk,
			pipe_rst => pipe_rst,
			pipe_en	=> pipe_en,
			valid_in(0) => valid_in,
			valid_out(0) => valid_out,
			pipe_data_in	=> pipe_data_in,
			pipe_data_out   => pipe_data_out);

	pipe_clk <= not pipe_clk and clkEn after 10 ns;
	
	process
	begin
		-- reset the circuit
		pipe_rst <= '1';
		pipe_en	<= '1';
		valid_in <= '0';
		pipe_data_in <= (others => '0');

		wait for 100 ns;
	
		for i in 0 to 4 loop
		  wait until rising_edge(pipe_clk);
		end loop;  -- i

		pipe_rst <= '0';
		wait until rising_edge(pipe_clk);
		
		pipe_data_in <= std_logic_vector(to_unsigned(67372036, data_width_in));

		valid_in <= '1';
		wait until rising_edge(pipe_clk);
		valid_in <= '0';
		wait until rising_edge(pipe_clk);
		wait until rising_edge(pipe_clk);
		wait until rising_edge(pipe_clk);

		assert(valid_out = '1') report "Valid_out incorrect" severity warning;
		
		assert(pipe_data_out = std_logic_vector(to_unsigned(32, data_width_out)))
				report "Output is incorrect.";
			
		wait for 100 ns;
		
		clkEn <= '0';
		
		wait;
	end process;  
end TB;
