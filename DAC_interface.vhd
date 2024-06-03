--Library
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.math_real.all;
library UNISIM;
use UNISIM.VComponents.all;

--=============================================================================
--Entity Declaration:
--=============================================================================
entity DAC_interface is
  Port ( 
    
    --timing:
    sclk 			 : in std_logic;

    --inputs:
    amp1_in : in std_logic_vector(9 downto 0);
    amp2_in : in std_logic_vector(9 downto 0);
    amp3_in : in std_logic_vector(9 downto 0);
    amp4_in : in std_logic_vector(9 downto 0);
    take_sample          : in std_logic; -- signal for 44 kHz sampler
    

    --outputs
    spi_CS               : out std_logic; 
    s_data		         : out std_logic);

end DAC_interface;

--=============================================================================
--Architecture Type:
--=============================================================================
architecture behavioral_architecture of DAC_interface is
--=============================================================================
--Component Declarations: 
--=============================================================================
component counter is 
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
  end component;
--=============================================================================
--Signal Declarations: 
--=============================================================================
--Control signals
    signal load_en             : std_logic; -- FSM to Register
    signal shift_en            : std_logic;
    signal bit_tc              : std_logic; --Bit counter to FSM
    signal bit_clr             : std_logic;

--Register signals
    signal reg                : std_logic_vector(15 downto 0);

--Controller signals
    type state_type is (sIdle, sLoad, sShift);
    signal next_state, current_state         : state_type := sIdle; 

--Counter signals
    signal shiftNum            : integer := 0;

    signal summed_amplitude    : std_logic_vector(11 downto 0);

    BEGIN

--========================== FSM Controller ===================================
stateUpdate : process(sclk)
    begin 
    if rising_edge(sclk) then
        current_state <= next_state;
    end if;
end process stateUpdate;

nextStateLogic : process(current_state, bit_tc, take_sample)
    begin
    next_state <= current_state; --Default
    case current_state is
        when sIdle =>
            if take_sample = '1' then --Wait for start bit
                next_state <= sLoad;
            end if; --Else stay Idle
        when sLoad =>
            next_state <= sShift;
        when sShift =>
            if bit_tc = '1' then --When done shifting all the bits
                next_state <= sIdle;
            end if;
        when others =>
    end case;
end process nextStateLogic;

outputLogic : process(current_state)
    begin
    load_en <= '0';
    spi_cs <= '1'; --Idles high, transmits low
    shift_en <= '0';
    bit_clr <= '1';
    case current_state is
        when sIdle => --Do default
            null;
        when sLoad => --Do one cycle of load
            load_en <= '1';
        when sShift => --Shift and transmit low
            shift_en <= '1';
            spi_cs <= '0';
            bit_clr <= '0';
    end case;
end process outputLogic;
--===============================================================================
--============================  Sub Count Proc ==================================
bit_counter : counter
generic map (
  MAX_COUNT => 16)
port map(
  clk => sclk,
  clr => bit_clr,
  en => shift_en,
  tc => bit_tc);

--================================================================================
shift_Register : process(sclk)
    begin
    if rising_edge(sclk) then
        if load_en = '1' then
            reg <= "0000" & not summed_amplitude(11) &  summed_amplitude(10 downto 0);
        elsif shift_en = '1' then --Should not be both on at any time
            reg <= reg(14 downto 0) & '0';
        end if;
    end if;
end process shift_Register;

--================================================================================


-- sum the amplitudes together
summed_amplitude <= std_logic_vector(unsigned("00" & amp1_in) + unsigned("00" & amp2_in) + unsigned("00" & amp3_in) + unsigned("00" & amp4_in));
-- Tie s_data to MSB of shift Register
s_data <= reg(15);
end behavioral_architecture;
