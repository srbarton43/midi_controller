--=============================================================================
--Library Declarations:
--=============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.math_real.all;
library UNISIM;
use UNISIM.VComponents.all;

--=============================================================================
--Entity Declaration:
--=============================================================================
entity counter is
  Generic (
    MAX_COUNT : integer
  );
  Port (
    --timing
    clk   : in std_logic;
    -- sync clear port
    clr   : in std_logic;
    -- enable counting
    en    : in std_logic;
    tc    : out std_logic);
end counter;

--=============================================================
--Architecture + Component Declarations
--=============================================================
architecture Behavioral of counter is
--=============================================================
--Local Signal Declaration
--=============================================================
signal count  : integer := 0;
signal tc_sig : std_logic := '0';

begin
  
  -- update count logic
  count_logic : process(clk, tc_sig, clr, en)
  begin
    if rising_edge(clk) then
      if en = '1' then
        count <= count + 1;
        if tc_sig = '1' then
          count <= 0;
        end if;
      end if;
      if clr = '1' then
        count <= 0;
      end if;
    end if;
  end process count_logic;

  -- terminal count logic
  tc_logic : process(count)
  begin
    tc_sig <= '0';
    if count = MAX_COUNT - 1 then
      tc_sig <= '1';
    end if;
  end process tc_logic;
  
  -- tie external port
  tc <= tc_sig;
  
end Behavioral;
