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
    m1_out   : out std_logic_vector(13 downto 0);
    m2_out   : out std_logic_vector(13 downto 0);
    m3_out   : out std_logic_vector(13 downto 0);
    m4_out   : out std_logic_vector(13 downto 0);
    v1_out : out std_logic_vector(2 downto 0);
    v2_out : out std_logic_vector(2 downto 0);
    v3_out : out std_logic_vector(2 downto 0);
    v4_out : out std_logic_vector(2 downto 0)
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

-- constants
constant MAX_KEYS       : integer := 4;
constant KEY_DOWN_CODE  : std_logic_vector(3 downto 0) := "1001";
constant KEY_UP_CODE    : std_logic_vector(3 downto 0) := "1000";

-- regfiles
type v_regfile_type is array(0 to MAX_KEYS-1) of std_logic_vector(2 downto 0);
type p_regfile_type is array(0 to MAX_KEYS-1) of std_logic_vector(6 downto 0);
type m_regfile_type is array(0 to MAX_KEYS-1) of std_logic_vector(13 downto 0);
signal vel_regfile    : v_regfile_type := (others => (others => '0'));
signal pitch_regfile  : p_regfile_type := (others => (others => '0'));
signal m_regfile      : m_regfile_type := (others => (others => '0'));

-- registers
signal B3_reg : std_logic_vector(7 downto 0) := (others => '0');
signal B2_reg : std_logic_vector(7 downto 0) := (others => '0');
signal B1_reg : std_logic_vector(7 downto 0) := (others => '0');

-- index counter
signal index : unsigned(2 downto 0) := "000";
signal index_tc : std_logic := '0';
-- check_regfile => enable
-- clear_index => clear

-- controller
type state_type is (idle, shifting, checkStatus, checkUp, checkDown, pressKey, releaseKey, delay, enableOut);
signal ns, cs : state_type := shifting;

-- control signals
signal status_byte : std_logic := '0';
signal shift_enable : std_logic := '0';
signal delay_count_enable : std_logic := '0';
signal delay_count_clear : std_logic := '1';
signal delay_count_tc : std_logic := '0';
signal enable_out_registers : std_logic := '0';
signal clear_index : std_logic := '1';
signal check_regfile : std_logic := '0';
signal press_key : std_logic := '0';
signal release_key : std_logic := '0';
signal is_empty : std_logic := '0';
signal is_down : std_logic := '0';

-- signals to output regs
signal brom_out : std_logic_vector(13 downto 0) := (others => '0'); 
signal key_down_signal : std_logic := '0';


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
next_state_logic : process(cs, rx_done, status_byte, delay_count_tc, index_tc, is_empty, is_down, key_down_signal)
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
        if key_down_signal = '1' then
          ns <= checkDown;
        else
          ns <= checkUp;
        end if;
      else
        ns <= idle;
      end if;
    when checkDown =>
      if is_empty = '1' or index_tc = '1' then
        ns <= pressKey;
      end if;
    when checkUp =>
      if is_down = '1' then
        ns <= releaseKey;
      elsif index_tc = '1' then
        ns <= idle; -- is this right??
      end if;
    when pressKey => ns <= delay;
    when releaseKey => ns <= delay; -- is this right??
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
  check_regfile <= '0';
  clear_index <= '0';
  press_key <= '0';
  release_key <= '0';
  case cs is 
    when idle => clear_index <= '1';
    when shifting => shift_enable <= '1';
    when checkUp => check_regfile <= '1';
    when checkDown => check_regfile <= '1';
    when pressKey => press_key <= '1';
    when releaseKey => release_key <= '1';
    when delay => delay_count_enable <= '1'; delay_count_clear <= '0';
    when enableOut => enable_out_registers <= '1';
    when others =>
  end case;
end process output_signal_logic;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Logic for the Regfile index counter
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++		
index_counter_clocked : process(sclk, index, check_regfile, clear_index)
begin
  if rising_edge(sclk) then
    if check_regfile = '1' then
      index <= index + 1;
    end if;
    if clear_index = '1' then
      index <= "000";
    end if;
  end if;
end process index_counter_clocked;

index_counter_async : process(index)
begin
  index_tc <= '0';
  if index = MAX_KEYS - 1 then
    index_tc <= '1';
  end if;
end process index_counter_async;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Logic for Regfiles
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   
check_pitch : process(pitch_regfile, B2_reg, index)
begin
  is_empty <= '0';
  is_down <= '0';
  if B2_reg(6 downto 0) = pitch_regfile(to_integer(index)) then
    is_down <= '1';
  end if;
  if pitch_regfile(to_integer(index)) = "0000000" then
    is_empty <= '1';
  end if;
end process check_pitch;

update_regfiles : process(sclk, B3_reg, B2_reg, index)
begin
  if rising_edge(sclk) then
    if press_key = '1' then
      pitch_regfile(to_integer(index)-1) <= B2_reg(6 downto 0);
    elsif release_key = '1' then
      pitch_regfile(to_integer(index)- 1) <= (others => '0');
    end if;
  end if;
end process update_regfiles;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Logic for Shifting Bytes through Registers:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++		
byte_shift_logic : process(sclk, shift_enable, byte_in, B3_reg, B2_reg, B1_reg)
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
      m_regfile(to_integer(index)-1) <= brom_out;
      vel_regfile(to_integer(index) - 1) <= B3_reg(6 downto 4); -- 3 MSBs
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
m1_out <= m_regfile(0);
m2_out <= m_regfile(1);
m3_out <= m_regfile(2);
m4_out <= m_regfile(3);
v1_out <= vel_regfile(0);
v2_out <= vel_regfile(1);
v3_out <= vel_regfile(2);
v4_out <= vel_regfile(3);

end behavioral;
