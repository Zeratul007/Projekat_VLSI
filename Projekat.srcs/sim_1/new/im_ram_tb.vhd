library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.RAM_definitions_PK.all;

entity im_ram_tb is
end im_ram_tb;

architecture Behavioral of im_ram_tb is
    constant C_CLK_PERIOD : time := 125 ms;
    
    -- Putanja do inicijalizacionog fajla, moze da bude puna putanja, a moze i samo ime fajla ako je fajl 
    -- na istoj lokaciji kao i source .vhd fajlovi
    --constant C_INIT_FILE_NAME: string := "init.dat"; 
    
    constant C_RAM_WIDTH : integer := 8;            		    -- Specify RAM data width
    constant C_RAM_DEPTH : integer := 256*256; 				    -- Specify RAM depth (number of entries)
    
    -- probati i jedan i drugi, primetiti da sa HIGH_PERFORMANCE memorija kasni dodatno jedan takt na izlazu
    constant C_RAM_PERFORMANCE : string := "LOW_LATENCY";  -- Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
    
    signal addra :  std_logic_vector((clogb2(C_RAM_DEPTH)-1) downto 0);     -- Write address bus, width determined from RAM_DEPTH
    signal addrb :  std_logic_vector((clogb2(C_RAM_DEPTH)-1) downto 0);     -- Read address bus, width determined from RAM_DEPTH
    signal dina  :  std_logic_vector(C_RAM_WIDTH-1 downto 0);		  -- RAM input data
    signal clka  :  std_logic := '1';                       			  -- Clock
    signal wea   :  std_logic := '0';                       			  -- Write enable
    signal enb   :  std_logic := '1';                       			  -- RAM Enable, for additional power savings, disable port when not in use
    signal rstb  :  std_logic := '0';                       			  -- Output reset (does not affect memory contents)
    signal regceb:  std_logic := '0';                       			  -- Output register enable
    signal doutb :  std_logic_vector(C_RAM_WIDTH-1 downto 0); 	
begin
    DUT: entity work.im_ram(Behavioral)
        generic map (
            G_RAM_WIDTH       => C_RAM_WIDTH,      
            G_RAM_DEPTH       => C_RAM_DEPTH,     
            G_RAM_PERFORMANCE => C_RAM_PERFORMANCE
        )
        port map (
            addra  => addra,
            addrb => addrb,
            clka   => clka,
            wea => wea,
            enb    => enb,
            rstb   => rstb,
            regceb => regceb,
            dina => dina,
            doutb  => doutb
        );

    clka <= not clka after C_CLK_PERIOD/2;
    
    READ_STIMULUS: process
    begin
        addrb <= std_logic_vector(to_unsigned(0, clogb2(C_RAM_DEPTH)));
        wait for C_CLK_PERIOD*2;
        
        regceb <= '1';
        addrb <= std_logic_vector(to_unsigned(255, clogb2(C_RAM_DEPTH)));
        wait for C_CLK_PERIOD;
        
        addrb <= std_logic_vector(to_unsigned(256, clogb2(C_RAM_DEPTH)));
        wait for C_CLK_PERIOD;
        
        addrb <= std_logic_vector(to_unsigned(257, clogb2(C_RAM_DEPTH)));
        wait for C_CLK_PERIOD;
        
        addrb <= std_logic_vector(to_unsigned(258, clogb2(C_RAM_DEPTH)));
        wait for C_CLK_PERIOD;        
        
        addrb <= std_logic_vector(to_unsigned(259, clogb2(C_RAM_DEPTH)));
        
        wait;
    end process READ_STIMULUS;
    
end Behavioral;