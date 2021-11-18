library ieee;
use ieee.std_logic_1164.all;

library work;
use work.Gates.all;

-- Entity to model an 8-bit Kogge-Stone adder
entity KoggeStoneAdder is
	port (
		A, B: in std_logic_vector(7 downto 0);
		Cout: out std_logic;
		S: out std_logic_vector(7 downto 0)
	);
end entity KoggeStoneAdder;

architecture Add of KoggeStoneAdder is
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
	level0: for i in 0 to 7 generate
		level0_lower: if i < 1 generate
			G1(i) <= G0(i);
			P1(i) <= P0(i);
		end generate level0_lower;
		level0_higher: if i > 0 generate
			prefix0: ProcessingComponent
			port map(Gin_1 => G0(i), Pin_1 => P0(i),
						Gin_2 => G0(i - 1), Pin_2 => P0(i - 1),
						Gout => G1(i), Pout => P1(i));
		end generate level0_higher;
	end generate;
	
	level1: for i in 0 to 7 generate
		level1_lower: if i < 2 generate
			G2(i) <= G1(i);
			P2(i) <= P1(i);
		end generate level1_lower;
		level1_higher: if i > 1 generate
			prefix1: ProcessingComponent
			port map(Gin_1 => G1(i), Pin_1 => P1(i),
						Gin_2 => G1(i - 2), Pin_2 => P1(i - 2),
						Gout => G2(i), Pout => P2(i));
		end generate level1_higher;
	end generate;
	
	level2: for i in 0 to 7 generate
		level2_lower: if i < 4 generate
			Gfinal(i) <= G2(i);
			Pfinal(i) <= P2(i);
		end generate level2_lower;
		level2_higher: if i > 3 generate
			prefix2: ProcessingComponent
			port map(Gin_1 => G2(i), Pin_1 => P2(i),
						Gin_2 => G2(i - 4), Pin_2 => P2(i - 4),
						Gout => Gfinal(i), Pout => Pfinal(i));
		end generate level2_higher;
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