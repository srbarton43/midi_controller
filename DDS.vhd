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

entity DDS is 
  port (
    sclk    : in  std_logic;
    m_in    : in  std_logic_vector(13 downto 0);
    v_in    : in std_logic_vector(2 downto 0);
    amp_out : out std_logic_vector(9 downto 0);
    take_sample : out std_logic
    );
end DDS;
  
--=============================================================
--Architecture + Component Declarations
--=============================================================
architecture Behavioral of DDS is
  COMPONENT counter is 
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
  END COMPONENT;
  
  COMPONENT dds_compiler_1
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_phase_tvalid : IN STD_LOGIC;
    s_axis_phase_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    m_axis_data_tvalid : OUT STD_LOGIC;
    m_axis_data_tdata : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
END COMPONENT;
  
--=============================================================
--Local Signal Declaration
--=============================================================
signal sample_tc : std_logic; --Terminal count sample rate counter
signal m         : unsigned(13 downto 0);
signal addr_count : unsigned(14 downto 0) := "000000000000000";
signal full_amp_sig : std_logic_vector(15 downto 0);  --LUT gives a 16 bit signal, will take first 12 bits to DAC
signal padded_addr : std_logic_vector(15 downto 0);
signal raw_amp : std_logic_vector(11 downto 0) := (others => '0');
signal amp_w_volume_padded : std_logic_vector(15 downto 0) := (others => '0');

--=============================================================
--Port Mapping + Processes:
--=============================================================
begin
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Sample rate Counter:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++		
sample_counter : counter
generic map (
  MAX_COUNT => 23)
port map(
  clk => sclk,
  clr => '0', --Maybe tie to something else
  en => '1', --Maybe tie to something else
  tc => sample_tc);

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--LUT
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Sine_LUT : dds_compiler_1
  PORT MAP (
    aclk => sclk,
    s_axis_phase_tvalid => '1', --Enable input
    s_axis_phase_tdata => padded_addr,
    m_axis_data_tvalid => open,
    m_axis_data_tdata => full_amp_sig
  );
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--LUT Address Counter: (unsigned adder that will rollover)
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++		
addr_count_logic : process(sclk, sample_tc, m)
begin
  if rising_edge(sclk) then
    if sample_tc = '1' then
     addr_count <= addr_count + m;            --Increment by M
    end if;
  end if;
end process addr_count_logic;
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Asynchronous
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
process(m_in)
begin
  raw_amp <= not full_amp_sig(11) & full_amp_sig(10 downto 0);  --Tie first 12 to amplitude output
  amp_w_volume_padded <= std_logic_vector(shift_right(unsigned(raw_amp), 3) * (1 + unsigned('0' & v_in)));
  amp_out <= amp_w_volume_padded(11 downto 2);
  
  if m_in = "00000000000000" then
    amp_out <= (others => '0');
  end if;
end process;
m <= unsigned(m_in);                   --M tied to M input, made unsigned
take_sample <= sample_tc;

padded_addr <= '0' & std_logic_vector(addr_count);

end Behavioral;
