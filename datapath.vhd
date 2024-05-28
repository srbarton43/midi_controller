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

entity datapath is 
  port (
    sclk    : in  std_logic;
    byte_in : in  std_logic_vector(7 downto 0);
    rx_done : in  std_logic;
    key_down : out std_logic;
    m_out   : out std_logic_vector(13 downto 0)
  );
end datapath;

--=============================================================
--Architecture + Component Declarations
--=============================================================
architecture behavioral of datapath is

-- block rom for m values
component datapath_m_BROM is
  port (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(13 DOWNTO 0)
  );
end component;

component counter is
  generic (
    MAX_COUNT : integer
  );
  port (
    clk : in std_logic;
    clr : in std_logic;
    en  : in std_logic;
    tc  : out std_logic
  );
end component;

--=============================================================
--Local Signal Declaration
--=============================================================

-- registers
signal B3_reg : std_logic_vector(7 downto 0) := (others => '0');
signal B2_reg : std_logic_vector(7 downto 0) := (others => '0');
signal B1_reg : std_logic_vector(7 downto 0) := (others => '0');
signal status_reg : std_logic := '0';
signal m_reg : std_logic_vector(13 downto 0) := (others => '0');

-- controller
type state_type is (idle, shifting, checkStatus, delay, enableOut);
signal ns, cs : state_type := shifting;

-- control signals
signal status_byte : std_logic := '0';
signal shift_enable : std_logic := '0';
signal delay_count_enable : std_logic := '0';
signal delay_count_clear : std_logic := '1';
signal delay_count_tc : std_logic := '0';
signal enable_out_registers : std_logic := '0';

-- output registers
signal brom_out : std_logic_vector(13 downto 0) := (others => '0'); 
signal key_down_signal : std_logic := '0';

-- constants
constant KEY_DOWN_CODE : std_logic_vector(3 downto 0) := "1001";
constant KEY_UP_CODE   : std_logic_vector(3 downto 0) := "1000";

--=============================================================
--Port Mapping + Processes:
--=============================================================
begin
  
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Block ROM:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++		
brom : datapath_m_BROM
  port map (
    clka => sclk,
    addra => B2_reg(6 downto 0),
    douta => brom_out);

delay_counter : counter
  generic map (
    MAX_COUNT => 3
              )
  port map (
    clk => sclk,
    en => delay_count_enable,
    clr => delay_count_clear,
    tc => delay_count_tc);

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Update State:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++		
update_state : process (sclk, ns)
begin
  if rising_edge(sclk) then
    cs <= ns;
  end if;
end process update_state;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Next State Logic:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++		
next_state_logic : process(cs, rx_done, status_byte, delay_count_tc)
begin
  ns <= cs;
  case cs is
    when idle =>
      if rx_done = '1' then
        ns <= shifting;
      end if;
    when shifting => ns <= checkStatus;
    when checkStatus => 
      if status_byte = '1' then
        ns <= delay;
      else
        ns <= idle;
      end if;
    when delay =>
      if delay_count_tc = '1' then
        ns <= enableOut;
      end if;
    when enableOut => ns <= idle;
  end case;
end process next_state_logic;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Output Signal Logic
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   
output_signal_logic : process(cs)
begin
  delay_count_clear <= '1';
  delay_count_enable <= '0';
  enable_out_registers <= '0';
  shift_enable <= '0';
  case cs is 
    when shifting => shift_enable <= '1';
    when delay => delay_count_enable <= '1'; delay_count_clear <= '0';
    when enableOut => enable_out_registers <= '1';
    when others =>
  end case;
end process output_signal_logic;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Logic for Shifting Bytes through Registers:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++		
byte_shift_logic : process(sclk, rx_done, byte_in, B3_reg, B2_reg, B1_reg)
begin
  if rising_edge(sclk) then
    if shift_enable = '1' then
      B3_reg <= byte_in;
      B2_reg <= B3_reg;
      B1_reg <= B2_reg;
    end if;
  end if;
end process byte_shift_logic;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Logic Output Registers
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++		
output_reg_logic : process(sclk, enable_out_registers, brom_out, key_down_signal)
begin
  if rising_edge(sclk) then
    if enable_out_registers = '1' then
      status_reg <= key_down_signal;
      m_reg <= brom_out;
    end if;
  end if;
end process output_reg_logic;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Async Status Signals Logic:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++		
status_signals_logic : process(B1_reg)
begin
  key_down_signal <= '0';
  status_byte <= '0';
  if B1_reg(7 downto 4) = KEY_UP_CODE then
    status_byte <= '1';
  elsif B1_reg(7 downto 4) = KEY_DOWN_CODE then
    status_byte <= '1';
    key_down_signal <= '1';
  end if;
end process status_signals_logic;

-- tie registers to output ports
m_out <= m_reg;
key_down <= status_reg;

end behavioral;
