library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity data_send_tb is
--  Port ( );
end data_send_tb;

architecture Behavioral of data_send_tb is

    constant C_CLK_PERIOD: time := 1 ns;
    
    component  data_send is
        port ( 
            clk : in std_logic;
            reset : in std_logic;
            start_transfer : in std_logic;
            start_filter : in std_logic;
            
            tx : out std_logic
        );
    end component;
    
    
    signal reset :  std_logic := '1';
    signal clk : std_logic  := '1' ;
    --signal comb : std_logic_vector(11 downto 0);
    signal start_transfer : std_logic := '0';
    signal start_filter : std_logic := '0';
    signal tx : std_logic;

begin
    DUT : entity work.data_send(Behavioral)
        port map (
            clk => clk,
            reset => reset,
            start_transfer => start_transfer,
            start_filter => start_filter,
            tx => tx
        );
    
    clk <= not clk after C_CLK_PERIOD/2;
    
    STIMULUS: process is
    begin
        reset <= '1';
        start_filter <= '0';
        wait for 5*C_CLK_PERIOD;
        
        reset <= '0';
        wait for 5*C_CLK_PERIOD;
        
        start_filter <= '1';
        wait for 50*C_CLK_PERIOD;
        start_filter <= '0';
        wait for 7000000*C_CLK_PERIOD;
        
        start_filter <= '1';
        wait for 50*C_CLK_PERIOD;
        start_transfer <= '0';
        
        wait;
    end process STIMULUS;

end Behavioral;