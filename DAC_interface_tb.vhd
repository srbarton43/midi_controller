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
entity DAC_interface_tb is
end entity;

--=============================================================================
--Architecture
--=============================================================================
architecture testbench of DAC_interface_tb is

--=============================================================================
--Component Declaration
--=============================================================================
component DAC_interface is
    Port ( 
      --timing:
      sclk		: in std_logic;

      --control inputs:
      start	      	: in std_logic;
      data_in        : in std_logic_vector(11 downto 0);

      --outputs:
      spi_CS	: out std_logic;
      s_data	: out std_logic)
    ;
end component;

--=============================================================================
--Signals
--=============================================================================

signal sclk       : std_logic := '0'; --Clock
signal key_down   : std_logic := '0'; --Simulated signal when key goes down, from datapath
signal p_data    : std_logic_vector(11 downto 0); --12 bits from Direct Digital Synthesis, loaded into reg

begin

--=============================================================================
--Port Map
--=============================================================================
uut: DAC_interface 
	port map(		
		sclk 	=> sclk,
		start 	=> key_down,
		data_in 	=> p_data
        );

--=============================================================================
--clk_4MHz generation 
--=============================================================================
clkgen_proc: process
begin
sclk <= '0';
wait for 20 ns;
sclk <= '1';
wait for 20 ns;

end process clkgen_proc;

--=============================================================================
--Stimulus Process
--=============================================================================
stim_proc: process
begin				

--Try loading in data from data_in
p_data <= "110011001100";
wait for 40 ns;
key_down <= '1';
wait for 720 ns; --Should load 1 cycle, then shift out 15 bits, starting with 3 leading zeroes and 12 data bits by MSB 
key_down <= '0';
wait for 1000 ns; --Should complete cycle it is on before stop, idle

--Try loading in some new data twice in a row while holding key down 
p_data <= "111100001010";
wait for 40 ns;
key_down <= '1';
wait for 1280 ns;
key_down <= '0';
wait for 100ns;
    wait;
end process stim_proc;

end testbench;
