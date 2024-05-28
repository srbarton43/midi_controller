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
entity DDS_tb is
end entity;

--=============================================================================
--Architecture
--=============================================================================
architecture testbench of DDS_tb is

--=============================================================================
--Component Declaration
--=============================================================================
component DDS is 
  port (
    sclk    : in  std_logic;
    m_in    : in  std_logic_vector(13 downto 0);
    amp_out : out std_logic_vector(11 downto 0)
    );
end component;

--=============================================================================
--Signals
--=============================================================================
signal sclk : std_logic;
signal m_data : std_logic_vector(13 downto 0);
signal amp_to_DAC    : std_logic_vector(11 downto 0);

CONSTANT clk_period : time := 40 ns;
CONSTANT sample_period : time := 23 * clk_period;

begin

--=============================================================================
--Port Map
--=============================================================================
uut: DDS
	port map(		
		sclk 	=> sclk,
		m_in    => m_data,
		amp_out     => amp_to_DAC
        );

--=============================================================================
--clk_4MHz generation 
--=============================================================================
clkgen_proc: process
begin
sclk <= '0';
wait for clk_period/2;
sclk <= '1';
wait for clk_period/2;

end process clkgen_proc;

--=============================================================================
--Stimulus Process
--=============================================================================
stim_proc: process
begin		
m_data <= "00000101000111"; --Equal to 327, should generate around 440Hz
wait for 30 * sample_period;
m_data <= "00001010001110";  --Equal to 654, should generate around 880Hz (one octave up)
wait for 30 * sample_period;
m_data <= "11111111111111"; --Very high frequency 
wait for 30 * sample_period;
m_data <= "00000000000001"; --Base frequency, 1.6 
wait for 60 * sample_period;

end process;
end testbench;
