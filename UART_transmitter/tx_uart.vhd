library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity UART_TX is
  generic (
    g_CLKS_PER_BIT : integer := 87     -- Needs to be set correctly
    );
  port (
    i_Clk       : in  std_logic;
    i_TX_DV     : in  std_logic; -- Data valid pulse
    i_TX_Byte   : in  std_logic_vector(7 downto 0);
    o_TX_Active : out std_logic;
    o_TX_Serial : out std_logic;
    o_TX_Done   : out std_logic
    );
end UART_TX;
 
 
architecture RTL of UART_TX is
 
  type type_SM is (s_idle, s_start_bit, s_data_bits, s_stop_bit, s_cleanup);
  
  signal r_SM_Main : type_SM := s_idle;
  signal clk_counter : integer range 0 to g_CLKS_PER_BIT-1 := 0;
  signal r_Bit_Index : integer range 0 to 7 := 0;  -- 8 Bits Total
  signal r_TX_Data   : std_logic_vector(7 downto 0) := (others => '0');
  signal r_TX_Done   : std_logic := '0';
   
begin 
  
    process (i_Clk)
    begin
        if rising_edge(i_Clk) then
         
            case r_SM_Main is
 
            when s_idle =>
                o_TX_Active <= '0';
                o_TX_Serial <= '1';         -- Drive Line High for Idle
                r_TX_Done   <= '0';
                clk_counter <= 0;
                r_Bit_Index <= 0;
                
                -- Send out Start Bit. Start bit = 0 when s_start_bit =>
                if i_TX_DV = '1' then
                    r_TX_Data <= i_TX_Byte;
                    r_SM_Main <= s_start_bit;
                else
                    r_SM_Main <= s_idle; 
                end if; 
                
                o_TX_Active <= '1'; -- high for entire transmittion proccess
                o_TX_Serial <= '0';
 
                -- Wait g_CLKS_PER_BIT clock cycles for start bit to finish
                if clk_counter < g_CLKS_PER_BIT then
                    clk_counter <= clk_counter + 1;
                    r_SM_Main   <= s_start_bit;
                else
                    clk_counter <= 0;
                    r_SM_Main   <= s_data_bits; 
                end if; -- Wait g_CLKS_PER_BIT-1 clock cycles for data bits to finish when s_data_bits =>
                o_TX_Serial <= r_TX_Data(r_Bit_Index);
                
                if clk_counter < g_CLKS_PER_BIT-1 then
                    clk_counter <= clk_counter + 1;
                    r_SM_Main   <= s_data_bits;
                else
                    clk_counter <= 0;
                    
                    -- Check if we have sent out all bits
                    if r_Bit_Index <= 7 then
                    if r_Bit_Index /= 7 then
                    r_Bit_Index <= r_Bit_Index + 1;
                    end if;
                    r_SM_Main   <= s_data_bits;
                    else
                    r_Bit_Index <= 0;
                    r_SM_Main   <= s_stop_bit; 
                    end if; 
                    end if; -- Send out Stop bit. Stop bit = 1 when s_stop_bit =>
                o_TX_Serial <= '1';

                -- Wait g_CLKS_PER_BIT-1 clock cycles for Stop bit to finish
                if clk_counter < g_CLKS_PER_BIT-1 then
                    clk_counter <= clk_counter + 1;
                    r_SM_Main   <= s_stop_bit;
                else
                    r_TX_Done   <= '1';
                    clk_counter <= 0;
                    r_SM_Main   <= s_cleanup; 
                end if; -- Stay here 1 clock when s_cleanup =>
                o_TX_Active <= '0';
                r_TX_Done   <= '1';
                r_SM_Main   <= s_idle; 
                when others =>
                r_SM_Main <= s_idle;
 
            end case;
        end if;
    end process;
 
    o_TX_Done <= r_TX_Done;
   
end RTL;
