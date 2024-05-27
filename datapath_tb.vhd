
--=============================================================
--Library Declarations
--=============================================================
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.all;

 --=============================================================
--Testbench Entity Declaration
--=============================================================
ENTITY datapath_tb IS
END datapath_tb;

--=============================================================
--Testbench declarations
--=============================================================
architecture testbench of datapath_tb is 

component datapath is
  Port (
    sclk    : in  std_logic;
    byte_in : in  std_logic_vector(7 downto 0);
    rx_done : in  std_logic;
    key_down : out std_logic;
    m_out   : out std_logic_vector(8 downto 0)
  );
end component;

--=============================================================
--Local Signal Declaration
--=============================================================
--inputs
signal system_clk     : std_logic := '0';
signal byte_in_sig    : std_logic_vector(7 downto 0) := (others => '0');
signal rx_done_sig    : std_logic := '0';
--outputs
signal key_down       : std_logic := '0';
signal m_out          : std_logic_vector(8 downto 0) := (others => '0'); 

constant CLK_PERIOD   : time := 1 us; -- 1 MHz clock

begin
  
uut: datapath
port map (
  sclk => system_clk,
  byte_in => byte_in_sig,
  rx_done => rx_done_sig,
  key_down => key_down,
  m_out => m_out);


-- clock signal 
clk_process : process
begin
  system_clk <= '0';
  wait for CLK_PERIOD / 2;
  system_clk <= '1';
  wait for CLK_PERIOD / 2;
end process clk_process;

stim_proc : process
begin
  -- key 100 down
  -- status byte
  wait for 10 * CLK_PERIOD;
  byte_in_sig <= "10011111";
  wait for 2 * CLK_PERIOD;
  rx_done_sig <= '1';
  wait for CLK_PERIOD;
  rx_done_sig <= '0';
  -- pitch byte
  wait for 10 * CLK_PERIOD;
  byte_in_sig <= "01100100";
  wait for 2 * CLK_PERIOD;
  rx_done_sig <= '1';
  wait for CLK_PERIOD;
  rx_done_sig <= '0';
  -- volume
  wait for 10 * CLK_PERIOD;
  byte_in_sig <= "00110010";
  wait for 2 * CLK_PERIOD;
  rx_done_sig <= '1';
  wait for CLK_PERIOD;
  rx_done_sig <= '0';

  -- weird bytes
  wait for 10 * CLK_PERIOD;
  byte_in_sig <= "11101111";
  wait for 2 * CLK_PERIOD;
  rx_done_sig <= '1';
  wait for CLK_PERIOD;
  rx_done_sig <= '0';
  wait for 10 * CLK_PERIOD;
  byte_in_sig <= "00111111";
  wait for 2 * CLK_PERIOD;
  rx_done_sig <= '1';
  wait for CLK_PERIOD;
  rx_done_sig <= '0';
  
  -- key 100 up
  -- status byte
  wait for 10 * CLK_PERIOD;
  byte_in_sig <= "10001111";
  wait for 2 * CLK_PERIOD;
  rx_done_sig <= '1';
  wait for CLK_PERIOD;
  rx_done_sig <= '0';
  -- pitch byte
  wait for 10 * CLK_PERIOD;
  byte_in_sig <= "01100100";
  wait for 2 * CLK_PERIOD;
  rx_done_sig <= '1';
  wait for CLK_PERIOD;
  rx_done_sig <= '0';
  -- volume
  wait for 10 * CLK_PERIOD;
  byte_in_sig <= "00000000";
  wait for 2 * CLK_PERIOD;
  rx_done_sig <= '1';
  wait for CLK_PERIOD;
  rx_done_sig <= '0';
  
  -- key 52 down
  -- status byte
  wait for 10 * CLK_PERIOD;
  byte_in_sig <= "10011111";
  wait for 2 * CLK_PERIOD;
  rx_done_sig <= '1';
  wait for CLK_PERIOD;
  rx_done_sig <= '0';
  -- pitch byte
  wait for 10 * CLK_PERIOD;
  byte_in_sig <= "00110100";
  wait for 2 * CLK_PERIOD;
  rx_done_sig <= '1';
  wait for CLK_PERIOD;
  rx_done_sig <= '0';
  -- volume
  wait for 10 * CLK_PERIOD;
  byte_in_sig <= "00110010";
  wait for 2 * CLK_PERIOD;
  rx_done_sig <= '1';
  wait for CLK_PERIOD;
  rx_done_sig <= '0';
  wait;
end process stim_proc;

end;
