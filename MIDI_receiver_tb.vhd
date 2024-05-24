
--=============================================================
--Library Declarations
--=============================================================
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.all;

 --=============================================================
--Testbench Entity Declaration
--=============================================================
ENTITY MIDI_receiver_tb IS
END MIDI_receiver_tb;

--=============================================================
--Testbench declarations
--=============================================================
architecture testbench of MIDI_receiver_tb is 

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
signal system_clk     : std_logic := '0';
signal MIDI_in        : std_logic := '0';
signal byte_out       : std_logic_vector(7 downto 0) := (others => '0');
signal rx_done        : std_logic := '0';

constant CLK_PERIOD   : time := 1 us; -- 1 MHz clock
constant BAUDRATE     : time := 32 us; -- 31.25 kb/s baudrate

begin
  
uut: MIDI_receiver
port map (
  sclk => system_clk,
  MIDI_in => MIDI_in,
  byte_out => byte_out,
  rx_done => rx_done);


-- clock signal 
clk_process : process
begin
  system_clk <= '0';
  wait for CLK_PERIOD / 2;
  system_clk <= '1';
  wait for CLK_PERIOD / 2;
end process clk_process;

stim_proc : process(system_clk)
begin
  wait for 3 * BAUDRATE;
  
  -- send status message for key down
  MIDI_in <= '0'; -- start bit
  wait for BAUDRATE;
  -- status bits
  MIDI_in <= '1';
  wait for BAUDRATE;
  MIDI_in <= '0';
  wait for BAUDRATE;
  MIDI_in <= '0';
  wait for BAUDRATE;
  MIDI_in <= '1';
  wait for BAUDRATE;
  -- channel bytes
  MIDI_in <= '1';
  wait for BAUDRATE;
  MIDI_in <= '1';
  wait for BAUDRATE;
  MIDI_in <= '1';
  wait for BAUDRATE;
  MIDI_in <= '1';
  wait for BAUDRATE;
  -- stop bit
  MIDI_in <= '1';
  wait for BAUDRATE;
  
  -- send status message for PITCH=100
  MIDI_in <= '0'; -- start bit
  wait for BAUDRATE;
  -- data bit signifier
  MIDI_in <= '0';
  wait for BAUDRATE;
  -- 7 pitch bits
  MIDI_in <= '1';
  wait for BAUDRATE;
  MIDI_in <= '1';
  wait for BAUDRATE;
  MIDI_in <= '0';
  wait for BAUDRATE;
  MIDI_in <= '0';
  wait for BAUDRATE;
  MIDI_in <= '1';
  wait for BAUDRATE;
  MIDI_in <= '0';
  wait for BAUDRATE;
  MIDI_in <= '0';
  wait for BAUDRATE;
  -- stop bit
  MIDI_in <= '1';
  wait for BAUDRATE;
  
  -- send status message for VOLUME=50
  MIDI_in <= '0'; -- start bit
  wait for BAUDRATE;
  -- data bit signifier
  MIDI_in <= '0';
  wait for BAUDRATE;
  -- 7 pitch bits
  MIDI_in <= '0';
  wait for BAUDRATE;
  MIDI_in <= '1';
  wait for BAUDRATE;
  MIDI_in <= '1';
  wait for BAUDRATE;
  MIDI_in <= '0';
  wait for BAUDRATE;
  MIDI_in <= '0';
  wait for BAUDRATE;
  MIDI_in <= '1';
  wait for BAUDRATE;
  MIDI_in <= '0';
  wait for BAUDRATE;
  -- stop bit
  MIDI_in <= '1';
  wait for BAUDRATE;
  wait;
end process stim_proc;

end;
