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
	signal G, P: std_logic_vector(7 downto 0) := (others => '0');
	signal C: std_logic_vector(8 downto 0) := (others => '0');
	
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
			port map(Gin_1 => G0(i - 1), Pin_1 => P0(i - 1),
						Gin_2 => G0(i), Pin_2 => P0(i),
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
			port map(Gin_1 => G1(i - 2), Pin_1 => P1(i - 2),
						Gin_2 => G1(i), Pin_2 => P1(i),
						Gout => G2(i), Pout => P2(i));
		end generate level1_higher;
	end generate;
	
	level2: for i in 0 to 7 generate
		level2_lower: if i < 4 generate
			G(i) <= G2(i);
			P(i) <= P2(i);
		end generate level2_lower;
		level2_higher: if i > 3 generate
			prefix2: ProcessingComponent
			port map(Gin_1 => G2(i - 4), Pin_1 => P2(i - 4),
						Gin_2 => G2(i), Pin_2 => P2(i),
						Gout => G(i), Pout => P(i));
		end generate level2_higher;
	end generate;
	
	-- Final computation
	post_process: for i in 0 to 7 generate
		-- Assuming no input carry for the time being
		C(i + 1) <= G(i);
		
		-- Final sum logic
		sum: XOR_2 
			port map(A => P(i), B => C(i), Y => S(i));
	end generate;
	Cout <= C(8);
	
end Add;