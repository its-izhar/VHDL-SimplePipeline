-- Greg Stitt
-- University of Florida

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

-- Concurrent statement examples. Concurrent statements are not part of a
-- process and are executed anytime one of their inputs changes.

architecture WITH_SELECT of mux_2x1 is
begin
  -- with_select is similar to the case statement, except that it can only be
  -- used outside of a process. The key difference from the when_else statement
  -- is that only one of the conditions can be true.
  with sel select
    output <= in1 when '0',
    in2           when others;

  -- the following would also work. In this version, you could potentially
  -- assign a different value (e.g. 'X') to the output when the select is not
  -- equal to either 0 or 1. For simulation, sel could potentially have any
  -- value defined by std_logic. However, for synthesis purposes, only '0' and
  -- '1' have a meaning. Therefore, I recommend the previous version.
--  with sel select
--    output <= in1 when '0',
--    in2           when '1',
--    'X'           when others;

  -- Important thing to remember: make sure to include "others", or
  -- alternatively you must specify a when clause for each possible value.

end WITH_SELECT;

architecture WHEN_ELSE of mux_2x1 is
begin

  -- when_else is similar to with_select, except that multiple conditions could
  -- potentially be true. Therefore, the order that the conditions are listed
  -- is important. For this example, there really is no difference from when_
  -- else, but for something where certain conditions have priority (e.g.
  -- priority encoders), when_else is more appropriate.
  output <= in1 when sel = '0' else
            in2;

  -- Like before, you have also done something like this for simulation
  -- purposes. However, I don't recommend this unless you have a good reason. 
--    output <= in1 when sel = '0' else
--              in2 when sel = '1' else
--              'X';

end WHEN_ELSE;

-- Sequential statement examples
-- Sequential statements execute sequentially within a process. During
-- simulation, a process executes everytime one of the signals in the
-- sensitivity list changes. Within the process, each statement is sequential.
-- However, this does not mean that the synthesized hardware will be
-- sequential. A process simply defines behavior sequentially, which the
-- synthesis tool converts into a circuit that has the same inputs and
-- produces the same outputs.

architecture IF_STATEMENT of mux_2x1 is
begin

  -- *********************************************************************
  -- Synthesis guideline for combinational logic: All inputs to the entity
  -- must be included in the sensitivity list.
  -- *********************************************************************
  --
  -- DON'T FORGET "SEL". Leaving an input out of the sensitivity list is a
  -- very common source of bugs. To see what happens, remove "sel" and run the
  -- provided testbench.

  process(in1, in2, sel)
  begin
    -- if statement is pretty straightforward.     
    if (sel = '0') then
      output <= in1;
    else
      output <= in2;
    end if;
  end process;
end IF_STATEMENT;

architecture CASE_STATEMENT of mux_2x1 is
begin

  -- same guideline as before, make sure all inputs are in the sensitivy list

  process(in1, in2, sel)
  begin
    -- case statement is similar to the if, but only one case can be true.
    case sel is
      when '0'    =>
        output <= in1;
      when others =>
        output <= in2;
    end case;

-- I sometimes do this also. The "null" for the others clause just specifies
-- that nothing should be done if sel isn't '0' or '1'. For synthesis, this
-- works fine because only '0' and '1' have a meaning.
-- case sel is
-- when '0' =>
-- output <= in1;
-- when '1' =>
-- output <= in2;
-- when others =>
-- null;
-- end case;
  end process;
end CASE_STATEMENT;
