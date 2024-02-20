----------------------------------------------------------------------------------
-- UART transmitter 
-- The component takes data from tx_data port and sends it serialy via tx port
-- using standardized UART interface. It requires information about operating
-- clock frequency and baudrate in compile time. We recommend to use 500000 bps 
-- for the purpose of the project. tx_dvalid indicates that the tx_data is
-- valid and should be kept high until tx_busy becomes '1'. When tx_busy becomes
-- '1' UART accepted the data and user can wait the transfer to be finished. When
-- transfer is finished tx_busy becomes '0'.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity uart_tx_tb is
--  Port ( );
end uart_tx_tb;

architecture Behavioral of uart_tx_tb is
    constant C_CLK_PERIOD : time := 8 ns;
    
    -- Control
	signal clk : std_logic := '1';		-- Main clock
	signal rst : std_logic := '0';		-- Main reset
	-- External Interface
	signal tx :	std_logic := '0';		-- RS232 transmitted serial data
	-- RS232/UART Configuration
	signal par_en :	std_logic := '0';		-- Parity bit enable
	-- uPC Interface
	signal tx_dvalid : std_logic := '0';						-- Indicates that tx_data is valid and should be sent
	signal tx_data : std_logic_vector(7 downto 0);	-- Data to transmit
	signal tx_busy : std_logic := '0';
    
begin
    DUT: entity work.uart_tx(Behavioral)
        port map (
            clk  => clk,
            rst => rst,
            tx => tx,
            par_en    => par_en,
            tx_dvalid   => tx_dvalid,
            tx_data => tx_data,
            tx_busy => tx_busy
        );
    clk <= not clk after C_CLK_PERIOD/2;
    READ_STIMULUS: process
    begin
        tx_data <= "10010011";
        wait for C_CLK_PERIOD*2;
        
        tx_dvalid <= '1';
        wait for 150*C_CLK_PERIOD;
        
        --tx_dvalid <= '0';
        wait for 25000*C_CLK_PERIOD;
        
        tx_data <= "11110011";
        wait for C_CLK_PERIOD*10;
        
--        tx_dvalid <= '1';
--        wait for 20*C_CLK_PERIOD;
        
--        tx_dvalid <= '0';
--        wait for 5*C_CLK_PERIOD;
        
        tx_data <= "10011111";
        wait for C_CLK_PERIOD*2;
        
--        tx_dvalid <= '1';
--        wait for 5*C_CLK_PERIOD;
        
--        tx_dvalid <= '0';
--        wait for 50*C_CLK_PERIOD;
        
        wait;
    end process READ_STIMULUS;
end Behavioral;
    