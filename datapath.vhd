-- Izhar Shaikh
-- University of Florida
--	
--	File : datapath.vhd
--	Description :
--		Implements a structural architecture of a simple "pipeline" consisting of two 8-bit multipliers and one 16-bit adder.
--		Since this is a pipeline, every entity is followed by a register.
--		This datapath will get inputs from an input memory and will write to output memory (BlockRAMs).
--		For reading and writing the data, address generators are used.
--		To control all of the abovementioned operation, a FSM is implemented in controller.vhd to control the synchronised operation.
--
----------------------------------------------------------------------------------------------------------------------------------------	

library ieee;
use ieee.std_logic_1164.all;

entity datapath is
    generic (
        data_width_in  : positive := 32 ;	-- Will be specified by the instance, but making it default to 32 for this application for now
        data_width_out : positive := 17		-- Will be specified by the instance, but making it default to 17 for this application for now
        );

    port (
        pipe_clk : in std_logic;
        pipe_rst : in std_logic;

		-- Enable for registers in each level of the pipeline
		pipe_en		: in std_logic;
		
        -- I/O interface
        valid_in        : in std_logic_vector(0 downto 0);
        valid_out       : out std_logic_vector(0 downto 0);
        pipe_data_in   	: in  std_logic_vector(data_width_in-1 downto 0);
		pipe_data_out   : out  std_logic_vector(data_width_out-1 downto 0));
end datapath;

architecture default of datapath is

	-- Different widths of registers at different L* levels of pipeline 
    constant C_PIPE_LEVEL_1_REG_WIDTH     : positive := 8;
    constant C_PIPE_LEVEL_2_REG_WIDTH     : positive := 16;
    constant C_1                          : positive := 1;

	-- Outputs from PIPELINE Level 1 Registers
    signal level_1_reg0_out      : std_logic_vector(C_PIPE_LEVEL_1_REG_WIDTH-1 downto 0);
    signal level_1_reg1_out      : std_logic_vector(C_PIPE_LEVEL_1_REG_WIDTH-1 downto 0);
    signal level_1_reg2_out      : std_logic_vector(C_PIPE_LEVEL_1_REG_WIDTH-1 downto 0);
    signal level_1_reg3_out      : std_logic_vector(C_PIPE_LEVEL_1_REG_WIDTH-1 downto 0);

	-- Outputs from PIPELINE Level 2 Registers
    signal level_2_reg0_out      : std_logic_vector(C_PIPE_LEVEL_2_REG_WIDTH-1 downto 0);
    signal level_2_reg1_out      : std_logic_vector(C_PIPE_LEVEL_2_REG_WIDTH-1 downto 0);	
	
	signal valid_reg0_out, valid_reg1_out, valid_reg2_out : std_logic_vector(0 downto 0);
	
begin

	------------------------------------------------------------------------------
	-- PIPELINE Level 1 (4 8bit registers)
	------------------------------------------------------------------------------
    U_PIPE_LEVEL_1_REG0 : entity work.reg
		generic map(
		    width => C_PIPE_LEVEL_1_REG_WIDTH )
        port map (
            clk     => pipe_clk,
            rst     => pipe_rst,
			en		=> pipe_en, 
			input	=> pipe_data_in( C_PIPE_LEVEL_1_REG_WIDTH-1 downto 0 ),		-- 7 downto 0
			output	=> level_1_reg0_out 
            );
			
    U_PIPE_LEVEL_1_REG1 : entity work.reg
		generic map(
			width => C_PIPE_LEVEL_1_REG_WIDTH )
        port map (
            clk     => pipe_clk,
            rst     => pipe_rst,
			en		=> pipe_en, 
			input	=> pipe_data_in( C_PIPE_LEVEL_1_REG_WIDTH*2-1 downto C_PIPE_LEVEL_1_REG_WIDTH ),	-- 15 downto 8
			output	=> level_1_reg1_out
            );
			
    U_PIPE_LEVEL_1_REG2 : entity work.reg
		generic map(
			width => C_PIPE_LEVEL_1_REG_WIDTH )
        port map (
            clk     => pipe_clk,
            rst     => pipe_rst,
			en		=> pipe_en, 
			input	=> pipe_data_in( C_PIPE_LEVEL_1_REG_WIDTH*3-1 downto C_PIPE_LEVEL_1_REG_WIDTH*2 ),	-- 23 downto 16
			output	=> level_1_reg2_out
            );

    U_PIPE_LEVEL_1_REG3 : entity work.reg
		generic map(
			width => C_PIPE_LEVEL_1_REG_WIDTH )
        port map (
            clk     => pipe_clk,
            rst     => pipe_rst,
			en		=> pipe_en, 
			input	=> pipe_data_in( C_PIPE_LEVEL_1_REG_WIDTH*4-1 downto C_PIPE_LEVEL_1_REG_WIDTH*3 ),	-- 31 downto 24
			output	=> level_1_reg3_out
            );			
	------------------------------------------------------------------------------

	
	------------------------------------------------------------------------------
	-- PIPELINE Level 2 (2 8bit Multipliers with 16bit registers on output of each multiplier)
	------------------------------------------------------------------------------
    U_MULT_PIPE_REG0 : entity work.mult_pipe
        generic map (
            width  => C_PIPE_LEVEL_1_REG_WIDTH)		-- Instantiate with LEVEL 1 width, because mult itself is piped (i.e. has register on the output having double the size of inputs)
        port map (
            clk   => pipe_clk,
			rst	  => pipe_rst,
			en	  => pipe_en,
			in1	  => level_1_reg0_out,
			in2	  => level_1_reg1_out,
			output => level_2_reg0_out
			);

    U_MULT_PIPE_REG1 : entity work.mult_pipe
        generic map (
            width  => C_PIPE_LEVEL_1_REG_WIDTH)		-- Instantiate with LEVEL 1 width, because mult itself is piped (i.e. has register on the output having double the size of inputs)
        port map (
            clk   => pipe_clk,
			rst	  => pipe_rst,
			en	  => pipe_en,
			in1	  => level_1_reg2_out,
			in2	  => level_1_reg3_out,
			output => level_2_reg1_out
			);			
	------------------------------------------------------------------------------


	------------------------------------------------------------------------------
	-- PIPELINE Level 3 (16bit Adder with registers on the output)
	------------------------------------------------------------------------------
    U_ADDR_PIPE_OUT_REG : entity work.add_pipe
        generic map (
            width  => C_PIPE_LEVEL_2_REG_WIDTH)		-- Instantiate with LEVEL 2 width, because adder itself is piped with carry included (i.e. has register on the output having width+1)
        port map (
            clk   => pipe_clk,
			rst	  => pipe_rst,
			en	  => pipe_en,
			in1	  => level_2_reg0_out,
			in2	  => level_2_reg1_out,
			output => pipe_data_out
			);	
	------------------------------------------------------------------------------	
	
	------------------------------------------------------------------------------
    -- Valid In/Out Registers
    ------------------------------------------------------------------------------
	U_VALID_REG_L1 : entity work.reg
	   generic map (width => C_1)
	   port map(
	       clk => pipe_clk,
	       rst => pipe_rst,
	       en  => pipe_en,
	       input => valid_in,
	       output => valid_reg0_out
	       );

	U_VALID_REG_L2 : entity work.reg
	   generic map (width => C_1)
	   port map(
	       clk => pipe_clk,
	       rst => pipe_rst,
	       en  => pipe_en,
	       input => valid_reg0_out,
	       output => valid_reg1_out
	       );
	       
	U_VALID_REG_L3 : entity work.reg
        generic map (width => C_1)
        port map(
          clk => pipe_clk,
          rst => pipe_rst,
          en  => pipe_en,
          input => valid_reg1_out,
          output => valid_out
          );	       


end default;
