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
component system_clock_generator is
    port (
        hw_clk		: in  std_logic;
        sclk	    : out std_logic);
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

--=============================================================
--Local Signal Declaration
--=============================================================
signal sclk_sig         : std_logic := '0';
signal rx_done_sig      : std_logic := '0';                   
signal byte_sig         : std_logic_vector(7 downto 0) := (others => '0');
signal key_down_sig     : std_logic := '0';
signal m_sig            : std_logic_vector(8 downto 0) := (others => '0');
signal ampl_sig         : std_logic_vector(11 downto 0) := (others => '0');

--=============================================================
--Port Mapping + Processes:
--=============================================================
begin
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Timing:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++		
clocking: system_clock_generator 
port map(
	hw_clk  => hw_clk_port,
	sclk 	  => sclk_sig);
sclk_port <= sclk_sig;

receiver : MIDI_receiver
port map(
  sclk => sclk_sig,
  MIDI_in => MIDI_in_port,
  byte_out => byte_sig,
  rx_done => rx_done_sig);
    
end Behavioral; 
