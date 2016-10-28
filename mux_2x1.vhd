-- Original Author: Greg Stitt
-- 
-- Author : Izhar Shaikh
-- University of Florida

-- Modifying the original source to have a generic structure.

library ieee;
use ieee.std_logic_1164.all;

use work.config_pkg.all;
use work.user_pkg.all;

entity mux_2x1 is
  generic ( DATA_WIDTH : positive := 8);
  port(
    in1    : in  std_logic_vector(DATA_WIDTH downto 0);
    in2    : in  std_logic_vector(DATA_WIDTH downto 0);
    sel    : in  std_logic;
    output : out std_logic_vector(DATA_WIDTH downto 0)
	);
end mux_2x1;

architecture WITH_SELECT of mux_2x1 is
begin

  with sel select
    output <= in1 when '0',
    in2           when others;

end WITH_SELECT;
