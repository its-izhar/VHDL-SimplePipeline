-- Izhar Shaikh
-- File: addr_generator.vhd
--
-- DESCRIPTION:
-- 		This file implements a FSMD architecture of the addr_generator entity, which can be utilized in two modes:
--
--		1. READ Mode - In this mode, the address generator will generate addressess in a sequential manner (0 to size),
--				along with the appropriate control signals which will read data from a BlockRAM.
--		2. WRITE Mode - In this mode, the address generator will generate addressess in a sequential manner (0 to size),
--				along with the appropriate control signals which write read data to a BlockRAM.
--
-------------------------------------------------------------------------------------------------------------------------
				
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.config_pkg.all;
use work.user_pkg.all;

entity addr_generator is

  generic (ADDR_WIDTH : positive := C_MEM_ADDR_WIDTH);
  port(clk      : in std_logic;
       rst      : in std_logic;
       
       -- Mode Control
       mode     : in std_logic;     -- '0': Read Mode, '1': Write Mode
       
       -- Size of memory (i.e. The number of addressess to be generated)
       size     : in std_logic_vector(C_MEM_ADDR_WIDTH downto 0);   
           
       -- Control I/O
       start    : in std_logic;
       done     : out std_logic;
              
       -- Write Control
       wr_en	: out std_logic;
       wr_addr	: out std_logic_vector(ADDR_WIDTH-1 downto 0);
       
       -- Read Control
       rd_addr	: out std_logic_vector(ADDR_WIDTH-1 downto 0);
	   
	   -- Select for input mux
	   pipeIn_mux_sel      : out std_logic;
       
       -- Valid Data I/O
       valid_in   : in std_logic;
       valid_out  : out std_logic );
	   
end addr_generator;


architecture default of addr_generator is
    
    type state_type is (S_WAIT_GO, S_INIT, S_MODE_CHECK, S_READ_MODE, S_WRITE_MODE, S_DONE);
    signal state : state_type;    
    
    constant C_READ_MODE : std_logic := '0';
    constant C_WRITE_MODE : std_logic := '1';
    
	constant C_START_ADDR  : unsigned(C_MEM_ADDR_WIDTH downto 0) := to_unsigned(0, C_MEM_ADDR_WIDTH+1);
    constant C_END_ADDR  : unsigned(C_MEM_ADDR_WIDTH downto 0) := to_unsigned(2**ADDR_WIDTH-1, C_MEM_ADDR_WIDTH+1);    
    
	-- register to hold the size provided by mmap (this will hold the end address)
    signal regSize  : std_logic_vector(C_MEM_ADDR_WIDTH downto 0) := (others => '0');
    
begin
  process(clk, rst) 
	variable count : unsigned(C_MEM_ADDR_WIDTH downto 0) := C_START_ADDR ;
  begin

    if rst = '1' then
        state  <= S_WAIT_GO;
        done <= '0';
        wr_en <= '0';
        wr_addr <= (others => '0');
        rd_addr <= (others => '0');
        valid_out <= '0';
		pipeIn_mux_sel <= '0';
        
    elsif (rising_edge(clk)) then

        case state is
            when S_WAIT_GO =>
                if(start = '1') then
                    state <= S_INIT;
                end if;
                
            when S_INIT =>
                count := C_START_ADDR;
                regSize <= size;     
                wr_en <= '0';
                wr_addr <= (others => '0');
                rd_addr <= (others => '0');
                valid_out <= '0';
				pipeIn_mux_sel <= '0';
				done <= '0';
                state <= S_MODE_CHECK;  -- Go to check the mode for this address generator
                
            when S_MODE_CHECK =>
                if(mode = C_READ_MODE) then          -- Read Mode
                    state <= S_READ_MODE;
                elsif (mode = C_WRITE_MODE) then     -- Write Mode
                    state <= S_WRITE_MODE;
                end if;
                
            when S_READ_MODE =>     -- READ Mode Starts here ...
				valid_out <= '0';
                if(count < unsigned(regSize)) then
                    rd_addr <= std_logic_vector(count(ADDR_WIDTH-1 downto 0));
					pipeIn_mux_sel <= '1';
                    valid_out <= '1';
                    count := count + 1;
                    state <= S_READ_MODE;
                else
					valid_out <= '0';
                    state <= S_DONE;
                end if;      
            
            when S_WRITE_MODE =>    -- WRITE Mode Starts here ...
                wr_en <= '0';
				if(valid_in = '1') then
                    wr_addr <= std_logic_vector(count(ADDR_WIDTH-1 downto 0));
                    wr_en <= '1';
                    count := count + 1;
                    if(count < unsigned(regSize)) then
                        state <= S_WRITE_MODE;
                    else
                        state <= S_DONE;
                    end if;
                end if;                
                
            when S_DONE =>
				pipeIn_mux_sel <= '0';
				wr_en <= '0';
				valid_out <= '0';
                done <= '1';
                if (start = '0') then
                    state <= S_WAIT_GO;
                end if;
            
            when others =>
                NULL;
        
        end case;
    end if;
  end process;
end default;
