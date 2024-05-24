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
entity MIDI_receiver is
  Port (
    -- inputs
    -- 1MHz clock
    sclk : in std_logic;
    -- serial midi bit
    MIDI_in : in std_logic;
    
    -- outputs
    -- byte of data
    byte_out : out std_logic_vector(7 downto 0);
    -- done receiving signal
    rx_done   : out std_logic);
end MIDI_receiver;
  
--=============================================================
--Architecture + Component Declarations
--=============================================================
architecture Behavioral of MIDI_receiver is
  component counter is 
    generic (
      MAX_COUNT : integer);
    port (
      --timing
      clk   : in std_logic;
      -- sync clear port
      clr   : in std_logic;
      -- enable counting
      en    : in std_logic;
      tc    : out std_logic);
  end component;
  
--=============================================================
--Local Signal Declaration
--=============================================================
  
-- controller
type state_type is (idle, wait0, shift0, wait1, shift1, byte_ready);
signal cs, ns : state_type := idle;
-- control signals
signal shift_en, clr_sig, bit_tc, rx_done_sig, baud_tc : std_logic := '0';

-- shift register
signal MSB_in : std_logic := '1'; -- sanitized input
signal shift_reg : std_logic_vector(9 downto 0) := (others => '0');

-- intermediate flip flop signal
signal inputFF : std_logic := '1';

--=============================================================
--Port Mapping + Processes:
--=============================================================
begin
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Baud Counter:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++		
baud_counter : counter
generic map (
  MAX_COUNT => 32)
port map(
  clk => sclk,
  clr => clr_sig,
  en => '1',
  tc => baud_tc);
  
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Bit Counter:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++		
bit_counter : counter
generic map (
  MAX_COUNT => 10)
port map(
  clk => sclk,
  clr => clr_sig,
  en => shift_en,
  tc => bit_tc);

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Update State:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++		
update_state : process(sclk, ns)
begin
  if rising_edge(sclk) then
    cs <= ns;
  end if;
end process update_state;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Next State Logic:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++		
next_state_logic : process(cs, MIDI_in, baud_tc, bit_tc)
begin
  ns <= cs;
  case cs is
    when idle => 
      if MIDI_in = '0' then
        ns <= cs;
      end if;
    when wait0 =>
      if baud_tc = '1' then
        ns <= shift1;
      end if;
    when shift0 => ns <= wait1;
    when wait1 => 
      if baud_tc = '1' then
        ns <= shift1;
      end if;
    when shift1 =>
      if bit_tc = '1' then
        ns <= byte_ready;
      else
        ns <= wait1;
      end if;
  end case;
end process next_state_logic;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Output Logic:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   
output_logic : process(cs)
begin
  clr_sig <= '0';
  shift_en <= '0';
  rx_done_sig <= '0';
  case cs is 
    when idle => clr_sig <= '1';
    when shift0 => shift_en <= '1';
    when shift1 => shift_en <= '1';
    when byte_ready => rx_done_sig <= '1';
    when others =>
  end case;
end process output_logic;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Shift Register Logic:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   
shift_reg_logic : process(sclk, MSB_in, shift_en)
begin 
  if rising_edge(sclk) then
    shift_reg <= MSB_in & shift_reg;
  end if;
end process shift_reg_logic;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Synchronizer Logic:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   
sanitize_input_logic : process(sclk)
begin
  if rising_edge(sclk) then
    inputFF <= MIDI_in;
    MSB_in <= inputFF;
  end if;
end process sanitize_input_logic;

-- tie pins to outputs
byte_out <= shift_reg(8 downto 1);
rx_done <= rx_done_sig;

end Behavioral;
