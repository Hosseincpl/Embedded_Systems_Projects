library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--------------------------------------------------------------------------------------
entity UP_COUNTER is
    Port ( clk		: in std_logic; -- clock input
           reset	: in std_logic; -- reset input 
           r_out	: out std_logic_vector(3 downto 0); -- output 4-bit counter (left)
	   l_out	: out std_logic_vector(3 downto 0); -- output 4-bit counter (right)
	   max_tick 	: out std_logic
     );
end UP_COUNTER;
--------------------------------------------------------------------------------------
architecture Behavioral of UP_COUNTER is
	signal counter_up: std_logic_vector(7 downto 0); -- output 8-bit counter
begin
-- up counter
	process(clk, reset)
	begin
		if(reset = '1') then
    			if(reset='1') then
         			counter_up <= x"0";
    			else if(clk' event and clk='1')
        			counter_up <= counter_up + x"1";
    			end if;
 		end if;
	end process;
counter <= counter_up;

end Behavioral;
--------------------------------------------------------------------------------------
