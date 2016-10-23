library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;

entity pipe_tb is
end pipe_tb;

architecture TB of pipe_tb is

    constant data_width_in  : positive := 32 ;
    constant data_width_out : positive := 17 ;
	constant MAX_INT_VAL : positive := 2**((data_width_in*3)/4)-1;

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
	
		-- Generate random input numbers
		procedure randInt(variable seed1, seed2 : inout positive;
						   min, max              : in    integer;
						   result                : out   integer) is
		  
		  variable                  rand         :       real;
		begin
		  uniform(seed1, seed2, rand);
		  result := integer(real(min)+(rand*(real(max)-real(min))));
		end procedure;	

		-- Function to check output
		function checkOutput (
			input : unsigned(data_width_in-1 downto 0))
			return unsigned is

			variable in1, in2, in3, in4 : unsigned(data_width_in/4-1 downto 0);
			variable temp1, temp2	: unsigned(data_width_in/2-1 downto 0);
		begin
			in1 := input(data_width_in/4-1 downto 0);
			in2 := input((data_width_in/4)*2-1 downto (data_width_in/4)*1);
			in3 := input((data_width_in/4)*3-1 downto (data_width_in/4)*2);
			in4 := input((data_width_in/4)*4-1 downto (data_width_in/4)*3);			
			temp1 := unsigned(in1)*unsigned(in2);
			temp2 := unsigned(in3)*unsigned(in4);
			return resize(temp1, data_width_in/2+1)+resize(temp2, data_width_in/2+1);
		end checkOutput;
		
		variable seed1, seed2 : positive;
		variable temp_int     : integer;		
	
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
		
		for i in 0 to 100 loop
			randInt(seed1, seed2, 0, MAX_INT_VAL, temp_int);
			pipe_data_in <= std_logic_vector(to_unsigned(temp_int, data_width_in));

			valid_in <= '1';
			wait until rising_edge(pipe_clk);
			valid_in <= '0';
			wait until rising_edge(pipe_clk);
			wait until rising_edge(pipe_clk);
			wait until rising_edge(pipe_clk);

			assert(valid_out = '1') report "Valid_out incorrect" severity warning;
			
			assert(unsigned(pipe_data_out) = checkOutput(to_unsigned(temp_int, data_width_in)))
					report "Output is incorrect.";

			for j in 0 to 4 loop
			  wait until rising_edge(pipe_clk);
			end loop;  -- i		
		
		end loop;
		
		wait for 100 ns;
		
		clkEn <= '0';
		
		wait;
	end process;  
end TB;
