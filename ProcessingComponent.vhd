library ieee;
use ieee.std_logic_1164.all;

library work;
use work.Gates.all;

-- Entity that performs intermediate computation to 
-- parallelize carry computation
entity ProcessingComponent is
	port (Gin_1, Pin_1: in std_logic;
			Gin_2, Pin_2: in std_logic;
			Gout, Pout: out std_logic);
end entity ProcessingComponent;

architecture Struct of ProcessingComponent is
	signal Pin_1_and_Gin_2: std_logic;
begin
	-- Pout = Pin_1 AND Pin_2
	compute_Pout: AND_2 
		port map(A => Pin_1, B => Pin_2, Y => Pout);
	
	-- Gout = Gin_1 OR (Pin_1 AND Gin_2)
	compute_Pin_1_and_Gin_2: AND_2 
		port map(A => Pin_1, B => Gin_2, Y => Pin_1_and_Gin_2);
	compute_Gout: OR_2 
		port map(A => Gin_1, B => Pin_1_and_Gin_2, Y => Gout);
end Struct;