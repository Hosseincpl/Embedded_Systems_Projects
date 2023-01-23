library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity UART_TX is
  generic (
    gen_clks_per_bit : integer := 87     -- change this int   
    );
  port (
    in_clk          : in  std_logic;
    in_data_valid   : in  std_logic; -- Data valid pulse
    in_serial_byte  : in  std_logic_vector(7 downto 0);
    out_active      : out std_logic;
    out_serial      : out std_logic;
    out_finish      : out std_logic
    );
end UART_TX;

architecture Behavioral of UART_TX is
 
    type type_SM is (s_idle, s_start_bit, s_data_bits, s_stop_bit, s_cleanup);

    signal s_current    : type_SM := s_idle;
    signal clk_counter  : integer range 0 to gen_clks_per_bit := 0;
    signal bit_index    : integer range 0 to 7 := 0;  -- 8 Bits Total
    signal data         : std_logic_vector(7 downto 0) := (others => '0');
    signal finish       : std_logic := '0';
   
 begin 
  
    process (in_clk)
    begin
        if rising_edge(in_clk) then
         
            case s_current is
 
            when s_idle =>
                out_active  <= '0';
                out_serial  <= '1';         -- Drive Line High for Idle
                finish      <= '0';
                clk_counter <= 0;
                bit_index   <= 0;
                
                -- Send out Start Bit. Start bit = 0 when s_start_bit =>
                if in_data_valid = '1' then
                    data <= in_serial_byte;
                    s_current <= s_start_bit;
                else
                    s_current <= s_idle; 
                end if; 
                
                out_active <= '1'; -- set high for entire transmittion proccess
                out_serial <= '0';
 
                -- Wait gen_clks_per_bit clock cycles for start bit to finish
                if clk_counter < gen_clks_per_bit then
                    clk_counter <= clk_counter + 1;
                    s_current   <= s_start_bit;
                else
                    clk_counter <= 0;
                    s_current   <= s_data_bits; 
                end if; 
                
                out_serial <= data(bit_index);
                
                if clk_counter < gen_clks_per_bit then
                    clk_counter <= clk_counter + 1;
                    s_current   <= s_data_bits;
                else
                    clk_counter <= 0;
                    
                    -- Check if we have sent out all bits
                    if bit_index <= 7 then
                        if bit_index /= 7 then
                            bit_index <= bit_index + 1;
                        end if;
                        s_current   <= s_data_bits;
                    else
                        bit_index <= 0;
                        s_current   <= s_stop_bit; 
                    end if; 
                end if; 
                -- Send out Stop bit. Stop bit = 1 when s_stop_bit =>
                out_serial <= '1';

                -- Wait gen_clks_per_bit-1 clock cycles for Stop bit to finish
                if clk_counter < gen_clks_per_bit-1 then
                    clk_counter <= clk_counter + 1;
                    s_current   <= s_stop_bit;
                else
                    finish   <= '1';
                    clk_counter <= 0;
                    s_current   <= s_cleanup; 
                end if; -- Stay here 1 clock when s_cleanup =>
                out_active <= '0';
                finish   <= '1';
                s_current   <= s_idle; 
                when others =>
                s_current <= s_idle;
 
            end case;
        end if;
    end process;
 
    out_finish <= finish;
   
end Behavioral;
