library ieee;
use ieee.std_logic_1164.all;

library work;
use work.Gates.all;

-- Entity to model an 8-bit Sklansky adder
entity SklanskyAdder is
	port (
		A, B: in std_logic_vector(7 downto 0);
		Cout: out std_logic;
		S: out std_logic_vector(7 downto 0)
	);
end entity SklanskyAdder;

architecture Add of SklanskyAdder is
	signal G0, P0: std_logic_vector(7 downto 0) := (others => '0');
	signal G1, P1: std_logic_vector(7 downto 0) := (others => '0');
	signal G2, P2: std_logic_vector(7 downto 0) := (others => '0');
	signal Gfinal, Pfinal: std_logic_vector(7 downto 0) := (others => '0');
	signal C: std_logic_vector(8 downto 0) := (others => '0');
	signal P_and_C: std_logic_vector(7 downto 0) := (others => '0');
	
	-- Component initialisation
	component Generator is 
		port(A, B: in std_logic; G, P: out std_logic);
	end component Generator;
	
	component ProcessingComponent is
		port (Gin_1, Pin_1: in std_logic;
				Gin_2, Pin_2: in std_logic;
				Gout, Pout: out std_logic);
	end component ProcessingComponent;
begin 
	-- Pre-compute P and G  
	pre_compute: for i in 0 to 7 generate
		add_instance : Generator 
			port map (A => A(i), B => B(i), G => G0(i), P => P0(i));
	end generate;
	
	-- There are 3 logic levels for prefix computation
	level0: for i in 0 to 3 generate
		prefix0: ProcessingComponent
		port map(Gin_1 => G0(2*i + 1), Pin_1 => P0(2*i + 1),
					Gin_2 => G0(2*i), Pin_2 => P0(2*i),
					Gout => G1(2*i + 1), Pout => P1(2*i + 1));
					
		G1(2*i) <= G0(2*i);
		P1(2*i) <= P0(2*i);
	end generate;
	
	level1: for i in 0 to 1 generate
		G2(4*i + 1 downto 4*i) <= G1(4*i + 1 downto 4*i);
		P2(4*i + 1 downto 4*i) <= P1(4*i + 1 downto 4*i);
		
		prefix1_1: ProcessingComponent
		port map(Gin_1 => G1(4*i + 2), Pin_1 => P1(4*i + 2),
					Gin_2 => G1(4*i + 1), Pin_2 => P1(4*i + 1),
					Gout => G2(4*i + 2), Pout => P2(4*i + 2));
					
		prefix1_2: ProcessingComponent
		port map(Gin_1 => G1(4*i + 3), Pin_1 => P1(4*i + 3),
					Gin_2 => G1(4*i + 1), Pin_2 => P1(4*i + 1),
					Gout => G2(4*i + 3), Pout => P2(4*i + 3));
	end generate;
	
	level2: for i in 0 to 0 generate
		Gfinal(8*i + 3 downto 8*i) <= G2(8*i + 3 downto 8*i);
		Pfinal(8*i + 3 downto 8*i) <= P2(8*i + 3 downto 8*i);
		
		prefix2_1: ProcessingComponent
		port map(Gin_1 => G2(8*i + 4), Pin_1 => P2(8*i + 4),
					Gin_2 => G2(8*i + 3), Pin_2 => P2(8*i + 3),
					Gout => Gfinal(8*i + 4), Pout => Pfinal(8*i + 4));
					
		prefix2_2: ProcessingComponent
		port map(Gin_1 => G2(8*i + 5), Pin_1 => P2(8*i + 5),
					Gin_2 => G2(8*i + 3), Pin_2 => P2(8*i + 3),
					Gout => Gfinal(8*i + 5), Pout => Pfinal(8*i + 5));
					
		prefix2_3: ProcessingComponent
		port map(Gin_1 => G2(8*i + 6), Pin_1 => P2(8*i + 6),
					Gin_2 => G2(8*i + 3), Pin_2 => P2(8*i + 3),
					Gout => Gfinal(8*i + 6), Pout => Pfinal(8*i + 6));
					
		prefix2_4: ProcessingComponent
		port map(Gin_1 => G2(8*i + 7), Pin_1 => P2(8*i + 7),
					Gin_2 => G2(8*i + 3), Pin_2 => P2(8*i + 3),
					Gout => Gfinal(8*i + 7), Pout => Pfinal(8*i + 7));
	end generate;
	
	-- Final computation
	post_process: for i in 0 to 7 generate
		-- Assuming no input carry for the time being
		-- Compute the next stage carry
		compute_Pi_and_Ci: AND_2
			port map(A => Pfinal(i), B => C(i), Y => P_and_C(i));
			
		compute_next_carry: OR_2
			port map(A => Gfinal(i), B => P_and_C(i), Y => C(i + 1));
		
		-- Final sum logic
		-- Here we use A XOR B computed in the first along
		-- with the carry computed in the intermediate
		-- stage. In case P = A + B and not P = A XOR B, 
		-- this stage is more complex but it additionally
		-- requires you to compute A XOR B
		sum: XOR_2 
			port map(A => P0(i), B => C(i), Y => S(i));
	end generate;
	Cout <= C(8);
	
end Add;