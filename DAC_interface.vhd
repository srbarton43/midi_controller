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

    --:
    start             : in std_logic; --signal that key has been pressed
    data_in              : in std_logic_vector(11 downto 0);

    --outputs
    spi_CS               : out std_logic; 
    s_data		         : out std_logic);

end DAC_interface;

--=============================================================================
--Architecture Type:
--=============================================================================
architecture behavioral_architecture of DAC_interface is
--=============================================================================
--Signal Declarations: 
--=============================================================================
--Control signals
    signal load_en             : std_logic; -- FSM to Register
    signal shift_en            : std_logic;
    signal bit_tc              : std_logic; --Bit counter to FSM

--Register signals
    signal reg                : std_logic_vector(14 downto 0);

--Controller signals
    type state_type is (sIdle, sLoad, sShift);
    signal next_state, current_state         : state_type := sIdle; 

--Counter signals
    signal shiftNum            : integer := 0;

    BEGIN

--========================== FSM Controller ===================================
stateUpdate : process(sclk)
    begin 
    if rising_edge(sclk) then
        current_state <= next_state;
    end if;
end process stateUpdate;

nextStateLogic : process(current_state, bit_tc, start)
    begin
    next_state <= current_state; --Default
    case current_state is
        when sIdle =>
            if start = '1' then --Wait for start bit
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
    case current_state is
        when sIdle => --Do default
            null;
        when sLoad => --Do one cycle of load
            load_en <= '1';
        when sShift => --Shift and transmit low
            shift_en <= '1';
            spi_cs <= '0';
    end case;
end process outputLogic;
--===============================================================================
--============================  Sub Count Proc ==================================

shiftCount : process(shift_en, sclk)
begin
if rising_edge(sclk) then
	if shift_en = '1' then 
	    if shiftNum < 14 - 1 then --If count is still less than max, increment. (careful timing)
	      bit_tc <= '0';
		  shiftNum <= shiftNum + 1;
		else --Else throw terminal count (to nextState)
		  bit_tc <= '1';
		  shiftNum <= 0;
	    end if;
	else  --Else if enable is not high, hold both signals at 0
	   shiftNum <= 0;
	   bit_tc <= '0'; --Set to 0 if not shifting
	end if;
end if;
end process shiftCount;

--================================================================================
shift_Register : process(sclk)
    begin
    if rising_edge(sclk) then
        if load_en = '1' then
            reg <= "000" & data_in;
        elsif shift_en = '1' then --Should not be both on at any time
            reg <= reg(13 downto 0) & '0';
        end if;
    end if;
end process shift_Register;

--Tie s_data to MSB of shift Register
    s_data <= reg(14);
end behavioral_architecture;