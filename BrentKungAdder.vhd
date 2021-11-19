library ieee;
use ieee.std_logic_1164.all;

library work;
use work.Gates.all;

-- Entity to model an 8-bit Brent-Kung adder
entity BrentKungAdder is
	port (
		A, B: in std_logic_vector(7 downto 0);
		Cout: out std_logic;
		S: out std_logic_vector(7 downto 0)
	);
end entity BrentKungAdder;

architecture Add of BrentKungAdder is
	signal G0, P0: std_logic_vector(7 downto 0) := (others => '0');
	signal G1, P1: std_logic_vector(7 downto 0) := (others => '0');
	signal G2, P2: std_logic_vector(7 downto 0) := (others => '0');
	signal G3, P3: std_logic_vector(7 downto 0) := (others => '0');
	signal G4, P4: std_logic_vector(7 downto 0) := (others => '0');
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
	
	-- There are 5 logic levels for prefix computation
	level0: for i in 0 to 3 generate
		prefix0: ProcessingComponent
		port map(Gin_1 => G0(2*i + 1), Pin_1 => P0(2*i + 1),
					Gin_2 => G0(2*i), Pin_2 => P0(2*i),
					Gout => G1(2*i + 1), Pout => P1(2*i + 1));
					
		G1(2*i) <= G0(2*i);
		P1(2*i) <= P0(2*i);
	end generate;
	
	level1: for i in 0 to 1 generate
		G2(4*i + 2 downto 4*i) <= G1(4*i + 2 downto 4*i);
		P2(4*i + 2 downto 4*i) <= P1(4*i + 2 downto 4*i);
		
		prefix1: ProcessingComponent
			port map(Gin_1 => G1(4*i + 3), Pin_1 => P1(4*i + 3),
						Gin_2 => G1(4*i + 1), Pin_2 => P1(4*i + 1),
						Gout => G2(4*i + 3), Pout => P2(4*i + 3));
	end generate;
	
	level2: for i in 0 to 0 generate
		G3(8*i + 6 downto 8*i) <= G2(8*i + 6 downto 8*i);
		P3(8*i + 6 downto 8*i) <= P2(8*i + 6 downto 8*i);
		
		prefix2: ProcessingComponent
			port map(Gin_1 => G2(8*i + 7), Pin_1 => P2(8*i + 7),
						Gin_2 => G2(8*i + 3), Pin_2 => P2(8*i + 3),
						Gout => G3(8*i + 7), Pout => P3(8*i + 7));
	end generate; 
	
	
	level3: ProcessingComponent
		port map(Gin_1 => G3(5), Pin_1 => P3(5),
					Gin_2 => G3(3), Pin_2 => P3(3),
					Gout => G4(5), Pout => P4(5));			
	G4(4 downto 0) <= G3(4 downto 0);
	P4(4 downto 0) <= P3(4 downto 0);
	G4(7 downto 6) <= G3(7 downto 6);
	P4(7 downto 6) <= P3(7 downto 6);
	
	level4: for i in 1 to 3 generate
		prefix0: ProcessingComponent
		port map(Gin_1 => G4(2*i), Pin_1 => P4(2*i),
					Gin_2 => G4(2*i -1), Pin_2 => P4(2*i - 1),
					Gout => Gfinal(2*i), Pout => Pfinal(2*i));
					
		Gfinal(2*i - 1) <= G4(2*i - 1);
		Pfinal(2*i - 1) <= P4(2*i - 1);
	end generate;
	Gfinal(7) <= G4(7);
	Pfinal(7) <= P4(7);
	Gfinal(0) <= G4(0);
	Pfinal(0) <= P4(0);
	
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