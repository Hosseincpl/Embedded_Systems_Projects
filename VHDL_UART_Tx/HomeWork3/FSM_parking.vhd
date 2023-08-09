-- s1 => empty space
-- s2 => entering
-- s3 => filled space
-- s4 => leaving

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-------------------------------------------
entity fsm_eg is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           a : in STD_LOGIC;
           b : in STD_LOGIC;
           Q : out STD_LOGIC_VECTOR(1 downto 0));
end fsm_eg;
-------------------------------------------
architecture mult_seg_arch of fsm_eg is
    type eg_state_type is (s1, s2, s3, s4);
    signal state_reg, state_next: eg_state_type;
begin
-- state register
    process(clk, reset)
    begin
        if (reset = '1') then 
            state_reg <= s1;
        elsif (clk' event and clk = '1') then
            state_reg <= state_next;
        end if;
    end process;

    -- next stage logic
    process (state_reg, a, b)
    begin 
        case state_reg is
        when s1 =>
            if a='1' then
                if b='1' then
                    state_next <= s3;
                else
                    state_next <= s2;
                end if;
            else
                state_next <= state_reg;
            end if;
        when s2 =>
            if b = '1' then
                state_next <= s3;
            elsif a = '0' then
                state_next <= s1;
            end if;
        when s3 =>
            if a = '0' then
                state_next <= s4;
            elsif b = '0' then
                state_next <= s2;
            end if; 
        when s4 =>
            if a = '1' then 
                state_next <= s3;
            elsif b = '0' then
                state_next <= s1;
            end if;
        end case;
    end process;

-- Moore output logic
    process (state_reg)
    begin 
        case state_reg is
            when s1 =>
                Q <= "00";
            when s2 =>
                Q <= "10";
            when s3 =>
                Q <= "11";
            when s4 =>
                Q <= "01";
        end case;
    end process;
end mult_seg_arch;
