library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package byte_vector_definition is
    type byte_vector is array (8 downto 0) of std_logic_vector(7 downto 0);
end byte_vector_definition;

package body byte_vector_definition is
    
end package body byte_vector_definition;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package fifo_definition is
    type fifo is array (252 downto 0) of std_logic_vector(7 downto 0);
end fifo_definition;

package body fifo_definition is
    
end package body fifo_definition;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package RAM_definitions_PK is
    impure function clogb2 (depth: in natural) return integer;
end RAM_definitions_PK;

package body RAM_definitions_PK is
    --  The following function calculates the address width based on specified RAM depth
    impure function clogb2( depth : natural) return integer is
        variable temp    : integer := depth;
        variable ret_val : integer := 0;
    begin
        while temp > 1 loop
            ret_val := ret_val + 1;
            temp    := temp / 2;
        end loop;
        return ret_val;
    end function;
end package body RAM_definitions_PK;




library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;
library work;
use work.RAM_definitions_PK.all;
use work.byte_vector_definition.all;
use work.fifo_definition.all;

entity data_send is
port (
	-- Control
	clk			: in	std_logic;		
	reset			: in	std_logic;		
	tx			: out	std_logic;		
	start_transfer  : in	std_logic;
	start_filter : in	std_logic
);
end data_send;

architecture Behavioral of data_send is
    
    signal edge1	:	std_logic;
    signal edge2	:	std_logic;
    
    signal read	:	std_logic;
    signal write	:	std_logic;
    
    signal data	:	std_logic_vector(7 downto 0);
    signal busy	:	std_logic;
    
    signal addr_cnt1	:	std_logic_vector((clogb2(256 * 256) - 1) downto 0);
    signal addr_cnt2	:	std_logic_vector((clogb2(256 * 256) - 1) downto 0);
    
    signal tx_dvalid	:	std_logic;
    signal busy_prev	:	std_logic;

    type State_t is ( stRead, stWait, stFilter);
    signal state_reg, next_state : State_t;
    
    signal a : byte_vector;
    signal fifo1 : fifo; --- array of 253 bytes
    signal fifo2 : fifo; --- array of 253 bytes
    signal med : std_logic_vector(7 downto 0);
    
    
    component im_ram is 
        generic (
        G_RAM_WIDTH : integer := 8;            		    -- Specify RAM data width
        G_RAM_DEPTH : integer := 256*256; 				        -- Specify RAM depth (number of entries)
        G_RAM_PERFORMANCE : string := "LOW_LATENCY"   -- Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    );
     port (
        addra : in std_logic_vector((clogb2(G_RAM_DEPTH)-1) downto 0);     -- Write address bus, width determined from RAM_DEPTH
        addrb : in std_logic_vector((clogb2(G_RAM_DEPTH)-1) downto 0);     -- Read address bus, width determined from RAM_DEPTH
        dina  : in std_logic_vector(G_RAM_WIDTH-1 downto 0);		  -- RAM input data
        clka  : in std_logic;                       			  -- Clock
        wea   : in std_logic;                       			  -- Write enable
        enb   : in std_logic;                       			  -- RAM Enable, for additional power savings, disable port when not in use
        rstb  : in std_logic;                       			  -- Output reset (does not affect memory contents)
        regceb: in std_logic;                       			  -- Output register enable
        doutb : out std_logic_vector(G_RAM_WIDTH-1 downto 0) 		  -- RAM output data
    );
    end component;
    
    component detector is 
        port ( 
        clk : in std_logic;
        reset : in std_logic;
        in_signal : in std_logic;
        edge : out std_logic
    );
    end component;

    component uart_tx is 
        generic (
            CLK_FREQ	: integer := 125;		-- Main frequency (MHz)
            SER_FREQ	: integer := 115200		-- Baud rate (bps)
        );
        port (
            -- Control
            clk			: in	std_logic;		-- Main clock
            rst			: in	std_logic;		-- Main reset
            -- External Interface
            tx			: out	std_logic;		-- RS232 transmitted serial data
            -- RS232/UART Configuration
            par_en		: in	std_logic;		-- Parity bit enable
            -- uPC Interface
            tx_dvalid   : in	std_logic;						-- Indicates that tx_data is valid and should be sent
            tx_data		: in	std_logic_vector(7 downto 0);	-- Data to transmit
            tx_busy     : out   std_logic                       -- Active while UART is busy and cannot receive data
        );
    end component;
    
    component sort_medijana is 
        port ( 
            clk : in std_logic;
            a : in byte_vector;
            smed : out std_logic_vector(7 downto 0)
  );
    end component;
    
    
begin
    RAM:
        im_ram
            port map (
                addrb  => addr_cnt1,
                clka   => clk,
                addra => addr_cnt2,
                dina => med,
                wea => write,
                enb => '1',
                rstb => reset,
                regceb   => '1',
                doutb  => data
            );
        
    UART:
        uart_tx
            port map (
                rst  => reset,
                clk   => clk,
                tx => tx,
                tx_dvalid => tx_dvalid,
                tx_busy => busy,
                tx_data => data,
                par_en   => '0'
            );        
    DETECT1:
        detector
            port map (
                reset  => reset,
                clk   => clk,
                in_signal => start_transfer,
                edge => edge1
            );
    DETECT2:
        detector
            port map (
                reset  => reset,
                clk   => clk,
                in_signal => start_filter,
                edge => edge2
            );   
    
    MEDIANA:
        sort_medijana  
            port map(
              clk => clk,
              a => a,
              smed => med
            );     
          
    STATE_TRANSITION: process (clk, reset) is
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state_reg <= stWait;
            else
                state_reg <= next_state;            
            end if;
        end if;
    end process STATE_TRANSITION;
    
    NEXT_STATE_LOGIC: process (edge1, edge2, state_reg, addr_cnt1, addr_cnt2) is
    begin
        case state_reg is
            when stWait =>
                if edge1 = '1'  then
                    next_state <= stRead;
                else
                    if edge2 = '1' then
                        next_state <= stFilter;
                    else 
                        next_state <= stWait;
                    end if;
                end if;
            when stRead =>
                if busy = '0' and addr_cnt1 = "1111111111111111" then
                    next_state <= stWait;
                else
                    next_state <= stRead;
                end if;
            when stFilter =>
                if addr_cnt2 = "1111111011111110" then
                    next_state <= stWait;
                else 
                    next_state <= stFilter;
                end if;   
        end case;
    end process NEXT_STATE_LOGIC;
    
    
    CNT_PROC: process(reset, clk) is
        variable addr_cnt_int1 : integer range 0 to 256*256 - 1;
        variable addr_cnt_int2 : integer range 0 to 256*256 - 1;
    begin
        addr_cnt_int1 := to_integer(unsigned(addr_cnt1));
        addr_cnt_int2 := to_integer(unsigned(addr_cnt2));
        if reset = '1' then
            addr_cnt1 <= (others => '0');
            addr_cnt2 <= "0000000100000001";
        else
            if rising_edge(clk) then
                if state_reg = stRead then
                    write <= '0';
                    if busy_prev = '1' and busy = '0' then
                        addr_cnt_int1 := addr_cnt_int1 + 1;
                        addr_cnt1 <= std_logic_vector(to_unsigned(addr_cnt_int1, addr_cnt1'length));      
                    end if;
                else
                    if state_reg = stFilter then
                        if addr_cnt_int1 > 522 then
                            write <= '1';
                            addr_cnt_int1 := addr_cnt_int1 + 1;
                            addr_cnt_int2 := addr_cnt_int2 + 1;
                            addr_cnt1 <= std_logic_vector(to_unsigned(addr_cnt_int1, addr_cnt1'length));
                            addr_cnt2 <= std_logic_vector(to_unsigned(addr_cnt_int2, addr_cnt2'length));
                        else
                            write <= '0';
                            addr_cnt_int1 := addr_cnt_int1 + 1;
                            addr_cnt1 <= std_logic_vector(to_unsigned(addr_cnt_int1, addr_cnt1'length));
                        end if;   
                    else
                        addr_cnt2 <= "0000000100000001";
                        addr_cnt1 <= (others => '0');
                        write <= '0';
                    end if;
                end if;
                busy_prev <= busy;
            end if;           
        end if;
        
    end process;
    
    BUFFER_PROC: process (clk) is
    variable addr_cnt_int1 : integer range 0 to 256*256 - 1;
    begin
        addr_cnt_int1 := to_integer(unsigned(addr_cnt1));
        if rising_edge(clk) then
            if state_reg = stFilter then
                case addr_cnt_int1 is
                    when 0 to 2 =>  
                        a(addr_cnt_int1) <= data;
                    when 3 to 255 =>                           
                        fifo1(addr_cnt_int1 - 3) <= data;              
                    when 256 to 258 =>                
                        a(addr_cnt_int1 - 253) <= data;            
                    when 259 to 511 =>               
                        fifo2(addr_cnt_int1 - 259) <= data;     
                    when 512 to 514 =>
                        a(addr_cnt_int1 - 506) <= data;
                    when others =>
                        a(0) <= a(1);
                        a(1) <= a(2);
                        a(2) <= fifo1(0);
                        
                        a(3) <= a(4);
                        a(4) <= a(5);
                        a(5) <= fifo2(0);
                        
                        a(6) <= a(7);
                        a(7) <= a(8);
                        a(8) <= data;
                        
                        LOOP_1: for i in 0 to 251 loop
                            fifo2(i) <= fifo2(i + 1);
                            fifo1(i) <= fifo1(i + 1);
                         end loop LOOP_1;    
                        
                        fifo1(252) <= a(3);
                        fifo2(252) <= a(6);
                end case;          
            end if;
        end if;
        
    end process;
    
--    SHIFT_PROC: process(clk) is
--    variable addr_cnt_int1 : integer range 0 to 256*256 - 1;
--    begin
--    addr_cnt_int1 := to_integer(unsigned(addr_cnt1));
--        if rising_edge(clk) then
--            if state_reg = stFilter then
--                if  addr_cnt_int1 >= 514 then
--                    a(0) <= a(1);
--                    a(1) <= a(2);
--                    a(2) <= fifo1(0);
                    
--                    a(3) <= a(4);
--                    a(4) <= a(5);
--                    a(5) <= fifo2(0);
                    
--                    a(6) <= a(7);
--                    a(7) <= a(8);
--                    a(8) <= data;
                    
--                    LOOP_1: for i in 0 to 251 loop
--                        fifo2(i) <= fifo2(i + 1);
--                        fifo1(i) <= fifo1(i + 1);
--                     end loop LOOP_1;    
                    
--                    fifo1(252) <= a(3);
--                    fifo2(252) <= a(6);
--                end if;
--            end if;
--        end if;                 
--    end process;


    OUTPUT_LOGIC: process (state_reg) is
    begin
        if state_reg = stRead then
            tx_dvalid <= '1';
        else
            tx_dvalid <= '0';
        end if;
         
    end process OUTPUT_LOGIC;
    
end Behavioral;