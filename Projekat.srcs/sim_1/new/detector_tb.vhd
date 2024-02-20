library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity detector_tb is
--  Port ( );
end detector_tb;

architecture Behavioral of detector_tb is
    
    constant C_CLK_PERIOD: time := 8 ns;
    
    component detector is
        port ( 
            clk : in std_logic;
            reset : in std_logic;
            in_signal : in std_logic;
            edge : out std_logic
        );
    end component;
    
    signal clk_tb : std_logic := '1';
    signal reset : std_logic;
    signal in_signal : std_logic;
    signal edge : std_logic;
    
begin
    DUT : detector 
        port map (
            clk => clk_tb,
            reset => reset,
            in_signal => in_signal,
            edge => edge
        );
    
    clk_tb <= not clk_tb after C_CLK_PERIOD/2;
    
    STIMULUS: process is
    begin
        reset <= '1';
        in_signal <= '0';
        wait for C_CLK_PERIOD*3.2;
        reset <= '0';
        wait for C_CLK_PERIOD*2;
        in_signal <= '1';
        wait for C_CLK_PERIOD*5;
        in_signal <= '0';
        wait for C_CLK_PERIOD*2;
        in_signal <= '1';
        wait for C_CLK_PERIOD*2;
        reset <= '1';
        wait;
    end process STIMULUS;
end Behavioral;
