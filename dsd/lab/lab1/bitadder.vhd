library IEEE; 
USE IEEE.STD_LOGIC_1164.ALL; 
USE IEEE.STD_LOGIC_ARITH.ALL; 
USE IEEE.STD_LOGIC_UNSIGNED.ALL; 
entity bitadder is  
port (A: in std_logic; 
B: in std_logic; 
C: in std_logic;  
sum: out std_logic; 
cout : out std_logic); 
end bitadder; 
architecture behavorial of bitadder is  
begin  
sum<= A xor B xor C; 
cout<= (A and B) or (A and C) or (B and c);   
end behavorial;  