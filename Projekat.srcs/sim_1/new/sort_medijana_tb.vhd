
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


package byte_vector_definition is
    type byte_vector is array (8 downto 0) of std_logic_vector(7 downto 0);
end byte_vector_definition;

package body byte_vector_definition is
    
end package body byte_vector_definition;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.byte_vector_definition.all;

entity sort_medijana_tb is
--  Port ( );
end sort_medijana_tb;

architecture Behavioral of sort_medijana_tb is
    constant C_CLK_PERIOD: time := 1 ms;
    component sort_medijana is
        port ( 
            clk : in std_logic;
            a : in byte_vector;
            smed : out std_logic_vector(7 downto 0)
        );
    end component;
    signal a : byte_vector;
    signal smed : std_logic_vector(7 downto 0);
    signal clk : std_logic := '1';
begin
    DUT : sort_medijana 
            port map (
                clk => clk,
                a => a,
                smed => smed
            );
    
    clk <= not clk after C_CLK_PERIOD/2;
    
    STIMULUS: process is
        begin
            a(0) <= "00000111";
            a(1) <= "00000011";
            a(2) <= "00000101";
            a(3) <= "00000001";
            a(4) <= "00000100";
            a(5) <= "00000010";
            a(6) <= "00000110";
            a(7) <= "00000000";
            a(8) <= "00001001";
--            in_signal <= '0';
            wait for 10*C_CLK_PERIOD;
            
            a(5) <= "11110001";
            a(6) <= "00010101";
            a(7) <= "00001100";
            
            wait for 10*C_CLK_PERIOD;
             
             
            a(0) <= "11110001";
            a(1) <= "01101100";
            a(2) <= "01011000";
--            reset <= '0';
--            wait for C_CLK_PERIOD*2;
--            in_signal <= '1';
--            wait for C_CLK_PERIOD*5;
--            in_signal <= '0';
--            wait for C_CLK_PERIOD*2;
--            in_signal <= '1';
--            wait for C_CLK_PERIOD*2;
            wait;
        end process STIMULUS;
end Behavioral;
