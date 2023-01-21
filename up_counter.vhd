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
	signal output_vector	: std_logic_vector(7 downto 0); -- output 8-bit counter;
	signal r_reg		: unsigned (7 downto 0);
	signal r_next		: unsigned (7 downto 0);
begin
-- up counter
	process(clk, reset)
	begin
		if(reset = '1') then
			r_reg <= (others => '0');
    		else if(clk' event and clk='1')
        		r_reg <= r_next;
 		end if;
	end process;
r_next <= r_reg +1;

-- output logic
output_vector <= std_logic_vector(r_reg);
r_out <= output_vector(3 downto 0);
l_out <= output_vector(7 downto 4);
max_tick <= '1' when r_reg = 99 else '0';
end Behavioral;
