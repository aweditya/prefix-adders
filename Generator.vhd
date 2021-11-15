library ieee;
use ieee.std_logic_1164.all;

library work;
use work.Gates.all;

-- Generator computes the generate and propogate terms
-- in the prefix graph
entity Generator is
	port(A, B: in std_logic; G, P: out std_logic);
end entity Generator;

-- Structural description of the generator
architecture Struct of Generator is
begin
	-- Carry generation logic G = A.B
	generate: AND_2 port map (A => A, B => B, Y => G);
	
	-- Carry propagation logic P = A XOR B
	-- Because of the way P is used, we can
	-- also use P = A + B
	
	-- propagate: XOR_2 port map (A => A, B => B, Y => P);
	propagate: OR_2 port map (A => A, B => B, Y => P);
end Struct;