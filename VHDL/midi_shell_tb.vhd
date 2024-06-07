--=============================================================
--Library Declarations
--=============================================================
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.all;

 --=============================================================
--Testbench Entity Declaration
--=============================================================
ENTITY midi_shell_tb IS
END midi_shell_tb;

--=============================================================
--Testbench declarations
--=============================================================
architecture testbench of midi_shell_tb is 

component midi_top_level is
  Port (
	  hw_clk_port     	: in  std_logic;		  -- ext 100 MHz clock
	  midi_in_port		  : in  std_logic;			-- async midi signal
    spi_cs_port	      : out std_logic;		  -- spi chip select
	  spi_data_port			: out std_logic;			-- spi data out
    spi_sclk_port     : out std_logic       -- sclk out for spi
  );
end component;

--=============================================================
--Local Signal Declaration
--=============================================================
--inputs
signal midi_in_sig : std_logic := '1';
signal hw_clk : std_logic := '0';
signal spi_cs_port : std_logic := '0';
signal spi_data_port : std_logic := '0';
signal spi_sclk_port : std_logic := '0';

constant CLK_PERIOD   : time := 10 ns; -- 100 MHz hw clock
constant BAUDRATE     : time := 32 us; -- 31.25 kb/s baudrate

begin
  
uut: midi_top_level
port map (
	hw_clk_port => hw_clk,
	midi_in_port => midi_in_sig,
  spi_cs_port	=> spi_cs_port,
	spi_data_port	=> spi_data_port,
  spi_sclk_port => spi_sclk_port);


-- clock signal 
clk_process : process
begin
  hw_clk <= '0';
  wait for CLK_PERIOD / 2;
  hw_clk <= '1';
  wait for CLK_PERIOD / 2;
end process clk_process;

stim_proc : process
begin
  wait for 3 * BAUDRATE;
  
  -- send status message for key down
  midi_in_sig <= '0'; -- start bit
  wait for BAUDRATE;
  -- channel bytes
  midi_in_sig <= '1';
  wait for BAUDRATE;
  midi_in_sig <= '1';
  wait for BAUDRATE;
  midi_in_sig <= '1';
  wait for BAUDRATE;
  midi_in_sig <= '1';
  wait for BAUDRATE;
  -- status bits
  midi_in_sig <= '1';
  wait for BAUDRATE;
  midi_in_sig <= '0';
  wait for BAUDRATE;
  midi_in_sig <= '0';
  wait for BAUDRATE;
  midi_in_sig <= '1';  
  wait for BAUDRATE;
  -- stop bit
  midi_in_sig <= '1';
  wait for 5*BAUDRATE;
  
  -- send status message for PITCH=100
  midi_in_sig <= '0'; -- start bit
  wait for BAUDRATE;
  -- 7 pitch bits
  midi_in_sig <= '0';
  wait for BAUDRATE;
  midi_in_sig <= '0';
  wait for BAUDRATE;
  midi_in_sig <= '1';
  wait for BAUDRATE;
  midi_in_sig <= '0';
  wait for BAUDRATE;
  midi_in_sig <= '0';
  wait for BAUDRATE;
  midi_in_sig <= '1';
  wait for BAUDRATE;
  midi_in_sig <= '1';
  wait for BAUDRATE;
  -- data bit signifier
  midi_in_sig <= '0';
  wait for BAUDRATE;
  -- stop bit
  midi_in_sig <= '1';
  wait for 5*BAUDRATE;
  
  -- send status message for VOLUME=50
  midi_in_sig <= '0'; -- start bit
  wait for BAUDRATE;
  -- 7 pitch bits
  midi_in_sig <= '0';
  wait for BAUDRATE;
  midi_in_sig <= '1';
  wait for BAUDRATE;
  midi_in_sig <= '0';
  wait for BAUDRATE;
  midi_in_sig <= '0';
  wait for BAUDRATE;
  midi_in_sig <= '1';
  wait for BAUDRATE;
  midi_in_sig <= '1';
  wait for BAUDRATE;
  midi_in_sig <= '0';
  wait for BAUDRATE;
  -- data bit signifier
  midi_in_sig <= '0';
  wait for BAUDRATE;
  -- stop bit
  midi_in_sig <= '1';
  wait for 5*BAUDRATE;
  wait;
end process stim_proc;

end;
