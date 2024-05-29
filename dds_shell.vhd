library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;			-- needed for arithmetic
use ieee.math_real.all;				-- needed for automatic register sizing
library UNISIM;						-- needed for the BUFG component
use UNISIM.Vcomponents.ALL;

--=============================================================
--Shell Entitity Declarations
--=============================================================
entity dds_top_level is
  port (
    hw_clk_port : in std_logic; -- 100 MHz clock
    spi_cs_port : out std_logic;		  -- spi chip select
	  spi_data_port	: out std_logic;			-- spi data out
    spi_sclk_port     : out std_logic;     -- sclk out for spi
    take_sample_port : out std_logic);
end dds_top_level;

--=============================================================
--Architecture + Component Declarations
--=============================================================
architecture Behavioral of dds_top_level is
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--System Clock Generation:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
component system_clock_generation is
    port (
        hw_clk		: in  std_logic;
        sclk	    : out std_logic;
        fwd_clk   : out std_logic);
end component;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--DDS:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
component DDS is
  port (
    --inputs
    sclk : in std_logic;
    m_in : in std_logic_vector(13 downto 0);
    --outputs
    amp_out : out std_logic_vector(11 downto 0);
    take_sample : out std_logic
  );
end component;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--DAC Interface:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
component DAC_interface is
  Port (
    -- inputs
    -- 1MHz clock
    sclk : in std_logic;
    -- start bit
    key_down : in std_logic;
    take_sample : in std_logic;
    -- parallel data input
    data_in : in std_logic_vector(11 downto 0);
    
    -- outputs
    -- bit of serial data out
    s_data : out std_logic;
    -- Chip select
    spi_CS : out std_logic
  );
end component;

--=============================================================
--Local Signal Declaration
--=============================================================
signal sclk_sig : std_logic := '0';
signal data_sig  : std_logic_vector(11 downto 0) := (others => '0');
signal take_sample_sig : std_logic := '0';

constant m_value : std_logic_vector(13 downto 0) := "00000101000111";
constant key_down : std_logic := '1';

--=============================================================
--Port Mapping + Processes:
--=============================================================
begin
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Timing:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++		
clocking: system_clock_generation 
port map(
	hw_clk  => hw_clk_port,
	sclk 	  => sclk_sig,
  fwd_clk => spi_sclk_port);

DDS_blk : DDS
port map(
  sclk => sclk_sig,
  m_in => m_value,
  amp_out => data_sig,
  take_sample => take_sample_sig
);

DAC : DAC_Interface
port map(
   sclk => sclk_sig, 
   data_in => data_sig,
   key_down => key_down,
   take_sample => take_sample_sig,
   s_data => spi_cs_port,
   spi_CS => spi_data_port
);

take_sample_port <= take_sample_sig;

end Behavioral;
