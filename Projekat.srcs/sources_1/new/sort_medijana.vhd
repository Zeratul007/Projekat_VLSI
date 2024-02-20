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

entity sort_medijana is
  port ( 
    clk : in std_logic;
    a : in byte_vector;
    smed : out std_logic_vector(7 downto 0)
  );
end sort_medijana;

architecture Behavioral of sort_medijana is
    
    signal stage1_out : byte_vector;
    signal stage2_out : byte_vector;
    signal stage3_out : byte_vector;
    signal stage4_out : byte_vector;
    signal stage5_out : byte_vector;
    signal stage6_out : byte_vector;
    
    signal med1 : std_logic_vector(7 downto 0);
    signal med2 : std_logic_vector(7 downto 0);
    signal s3 : std_logic_vector(7 downto 0);

begin
    STAGE_1: process(clk) is
    begin 
        LOOP_STAGE_1: for i in 0 to 3 loop
            if a(2*i) < a(2*i+1) then 
               stage1_out(2*i) <= a(2*i); 
               stage1_out(2*i + 1) <= a(2*i + 1);
            else
               stage1_out(2*i) <= a(2*i + 1);
               stage1_out(2*i + 1) <= a(2*i);
            end if;
        end loop LOOP_STAGE_1;
        
        stage1_out(8) <= a(8);
            
    end process;
    
    STAGE_2: process(clk) is
    begin
        if rising_edge(clk) then
            LOOP_STAGE_2: for i in 0 to 1 loop
                if stage1_out(i) < stage1_out(i + 2) then 
                   stage2_out(i) <= stage1_out(i); 
                   stage2_out(i + 2) <= stage1_out(i + 2);
                else
                   stage2_out(i) <= stage1_out(i + 2);
                   stage2_out(i + 2) <= stage1_out(i);
                end if;
                if stage1_out(i + 4) < stage1_out(i + 6) then 
                   stage2_out(i + 4) <= stage1_out(i + 4); 
                   stage2_out(i + 6) <= stage1_out(i + 6);
                else
                   stage2_out(i + 4) <= stage1_out(i + 6);
                   stage2_out(i + 6) <= stage1_out(i + 4);
                end if;
            end loop LOOP_STAGE_2;
        end if;     
        
        stage2_out(8) <= stage1_out(8);

    end process;
    
    

    STAGE_3: process(clk) is
    begin 
        if rising_edge(clk) then      
            if stage2_out(1) < stage2_out(2) then 
               stage3_out(1) <= stage2_out(1); 
               stage3_out(2) <= stage2_out(2);
            else
               stage3_out(1) <= stage2_out(2);
               stage3_out(2) <= stage2_out(1);
            end if;
            
            if stage2_out(5) < stage2_out(6) then 
               stage3_out(5) <= stage2_out(5); 
               stage3_out(6) <= stage2_out(6);
            else
               stage3_out(5) <= stage2_out(6);
               stage3_out(6) <= stage2_out(5);
            end if;
            
            stage3_out(0) <= stage2_out(0); 
            stage3_out(3) <= stage2_out(3);
            stage3_out(4) <= stage2_out(4);
            stage3_out(7) <= stage2_out(7);
            stage3_out(8) <= stage2_out(8);
        end if;
    end process;
    
    STAGE_4: process(clk) is
    begin     
        if rising_edge(clk) then
            LOOP_STAGE_4: for i in 0 to 3 loop
                if stage3_out(i) < stage3_out(i + 4) then 
                   stage4_out(i) <= stage3_out(i); 
                   stage4_out(i + 4) <= stage3_out(i + 4);
                else
                   stage4_out(i) <= stage3_out(i + 4);
                   stage4_out(i + 4) <= stage3_out(i);
                end if;
            end loop LOOP_STAGE_4;
            stage4_out(8) <= stage3_out(8);
            
        end if;
    end process;
    

    STAGE_5: process(clk) is
    begin 
        if rising_edge(clk) then
            LOOP_STAGE_5: for i in 2 to 3 loop
                if stage4_out(i) < stage4_out(i + 2) then 
                   stage5_out(i) <= stage4_out(i); 
                   stage5_out(i + 2) <= stage4_out(i + 2);
                else
                   stage5_out(i) <= stage4_out(i + 2);
                   stage5_out(i + 2) <= stage4_out(i);
                end if;
            end loop LOOP_STAGE_5;
            
            stage5_out(0) <= stage4_out(0);
            stage5_out(1) <= stage4_out(1);
            stage5_out(6) <= stage4_out(6);
            stage5_out(7) <= stage4_out(7);
            stage5_out(8) <= stage4_out(8);
        
        end if;
        
    end process; 

    STAGE_6: process(clk) is
    begin 
        if rising_edge(clk) then
            LOOP_STAGE_5: for i in 0 to 2 loop
                if stage5_out(2*i + 1) < stage5_out(2*i + 2) then 
                   stage6_out(2*i + 1) <= stage5_out(2*i + 1); 
                   stage6_out(2*i + 2) <= stage5_out(2*i + 2);
                else
                   stage6_out(2*i + 1) <= stage5_out(2*i + 2);
                   stage6_out(2*i + 2) <= stage5_out(2*i + 1);
                end if;
            end loop LOOP_STAGE_5;
            if stage5_out(0) < stage5_out(8) then 
               stage6_out(0) <= stage5_out(0); 
               stage6_out(8) <= stage5_out(8);
            else
               stage6_out(0) <= stage5_out(8);
               stage6_out(8) <= stage5_out(0);
            end if;
            stage6_out(7) <= stage5_out(7);
        end if;
    end process; 

    STAGE_7: process(clk) is
    begin
        if rising_edge(clk) then
            if stage6_out(4) < stage6_out(8) then    
                med1 <= stage6_out(4);
            else 
                med1 <= stage6_out(8);
            end if;
        end if;
     end process;
     
    STAGE_8: process(clk) is
    begin
        if rising_edge(clk) then
            if stage6_out(2) < med1 then    
                med2 <= med1;
            else 
                med2 <= stage6_out(2);
            end if;
            if stage6_out(3) < stage6_out(5) then    
                s3 <= stage6_out(3);
            else 
                s3 <= stage6_out(5);
            end if;
        end if;
    end process;
    
    STAGE_9:  process(clk) is   
    begin
        if rising_edge(clk) then
            if s3 < med2 then    
                smed <= med2;
            else 
                smed <= s3;
            end if;
        end if;
    end process;

end Behavioral;
