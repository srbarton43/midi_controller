--=============================================================
--Ben Dobbins
--ES31/CS56
--This script is the shell code for Lab 6, the voltmeter.
--Your name goes here: 
--=============================================================

--=============================================================
--Library Declarations
--=============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;			-- needed for arithmetic
use ieee.math_real.all;				-- needed for automatic register sizing
library UNISIM;						-- needed for the BUFG component
use UNISIM.Vcomponents.ALL;

--=============================================================
--Shell Entitity Declarations
--=============================================================
entity midi_top_level is
port (  
	hw_clk_port     	: in  std_logic;		  -- ext 100 MHz clock
	midi_in_port		  : in  std_logic;			-- async midi signal
  spi_cs_port	      : out std_logic;		  -- spi chip select
	spi_data_port			: out std_logic;			-- spi data out
  sclk_port         : out std_logic);     -- sclk out for spi
end midi_top_level; 

--=============================================================
--Architecture + Component Declarations
--=============================================================
architecture Behavioral of midi_top_level is
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
--MIDI Receiver:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
component MIDI_receiver is
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
end component;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Datapath:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
component datapath is 
  port (
    sclk    : in  std_logic;
    byte_in : in  std_logic_vector(7 downto 0);
    rx_done : in  std_logic;
    key_down : out std_logic;
    m_out   : out std_logic_vector(13 downto 0)
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
    start : in std_logic;
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
signal sclk_sig         : std_logic := '0';
signal rx_done_sig      : std_logic := '0';                   
signal byte_sig         : std_logic_vector(7 downto 0) := (others => '0');
signal key_down_sig     : std_logic := '0';
signal m_sig            : std_logic_vector(13 downto 0) := (others => '0');
signal ampl_sig         : std_logic_vector(11 downto 0) := (others => '0');

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
  fwd_clk => sclk_port);

receiver : MIDI_receiver
port map(
  sclk => sclk_sig,
  MIDI_in => MIDI_in_port,
  byte_out => byte_sig,
  rx_done => rx_done_sig);

dpath : datapath
port map(
  sclk => sclk_sig,
  byte_in => byte_sig,
  rx_done => rx_done_sig,
  key_down => key_down_sig,
  m_out => m_sig
);

DAC : DAC_Interface
port map(
   sclk => sclk_sig, 
   data_in => ampl_sig,
   start => key_down_sig,
   s_data => spi_cs_port,
   spi_CS => spi_data_port
);
    
end Behavioral; 
