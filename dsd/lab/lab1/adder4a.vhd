library IEEE; 
USE IEEE.STD_LOGIC_1164.ALL; 
USE IEEE.STD_LOGIC_ARITH.ALL; 
USE IEEE.STD_LOGIC_UNSIGNED.ALL; 
entity adder4a is  
port (A: in std_logic_vector(3 downto 0); 
B: in std_logic_vector(3 downto 0); 
C: in std_logic; 
sum: out std_logic_vector(3 downto 0); 
cout : out std_logic); 
end adder4a; 
architecture behavorial of adder4a is  
component bitadder is  
port (A: in std_logic; 
B: in std_logic; 
C: in std_logic; 
sum: out std_logic; 
cout : out std_logic); 
end component; 
signal w1, w2, w3: std_logic; 
begin 
unit1: bitadder port map (A(0), B(0),'0',sum(0),w1); 
unit2: bitadder port map  (A(1), B(1), w1, sum(1), w2); 
unit3: bitadder port map  (A(2), B(2), w2, sum(2), w3); 
unit4: bitadder port map  (A(3), B(3), w3, sum(3), cout); 
end behavorial; 