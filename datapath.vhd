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
    m_out   : out std_logic_vector(8 downto 0)
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
    ena : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(8 DOWNTO 0)
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
signal m_reg : std_logic_vector(8 downto 0) := (others => '0');

signal brom_out : std_logic_vector(8 downto 0) := (others => '0'); 
signal key_down_signal : std_logic := '0';
signal enable_out_registers : std_logic := '0';

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
    ena => enable_out_registers,
    addra => B2_reg(6 downto 0),
    douta => brom_out);


--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Logic for Shifting Bytes through Registers:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++		
byte_shift_logic : process(sclk, rx_done, byte_in, B3_reg, B2_reg, B1_reg)
begin
  if rising_edge(sclk) then
    if rx_done = '1' then
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
  enable_out_registers <= '0';
  if B1_reg(7 downto 4) = KEY_UP_CODE then
    enable_out_registers <= '1';
  elsif B1_reg(7 downto 4) = KEY_DOWN_CODE then
    enable_out_registers <= '1';
    key_down_signal <= '1';
  end if;
end process status_signals_logic;

-- tie registers to output ports
m_out <= m_reg;
key_down <= status_reg;

end behavioral;
