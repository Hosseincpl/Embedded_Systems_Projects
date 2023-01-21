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
    type eg_state_type is (A, B, C, D);
    signal state_reg, state_next: eg_state_type;
begin
-- state register
    process(clk, reset)
    begin
        if (reset = '1') then 
            state_reg <= A;
        elsif (clk' event and clk = '1') then
            state_reg <= state_next;
        end if;
    end process;

    -- next stage logic
    process (state_reg, a, b)
    begin 
        case state_reg is
        when A =>
            if a='1' then
                if b='1' then
                    state_next <= C;
                else
                    state_next <= B;
                end if;
            else
                state_next <= state_reg;
            end if;
        when B =>
            if b = '1' then
                state_next <= C;
            elsif a = '0' then
                state_next <= A;
            end if;
        when C =>
            if a = '0' then
                state_next <= D;
            elsif b = '0' then
                state_next <= B;
            end if; 
        when D =>
            if a = '1' then 
                state_next <= C;
            elsif b = '0' then
                state_next <= A;
            end if;
        end case;
    end process;

-- Moore output logic
    process (state_reg)
    begin 
        case state_reg is
            when A =>
                Q <= A;
            when B =>
                Q <= B;
            when C =>
                Q <= C;
            when D =>
                Q <= D;
        end case;
    end process;
end mult_seg_arch;
