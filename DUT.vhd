library ieee;
use ieee.std_logic_1164.all;

entity DUT is
   port(input_vector: in std_logic_vector(15 downto 0);
       	output_vector: out std_logic_vector(8 downto 0));
end entity;

architecture DutWrap of DUT is
   component SklanskyAdder is
		port (
			A, B: in std_logic_vector(7 downto 0);
			Cout: out std_logic;
			S: out std_logic_vector(7 downto 0)
		);
   end component;
begin

   add_instance: SklanskyAdder
			port map (
					A(7) => input_vector(15),
					A(6) => input_vector(14),
					A(5) => input_vector(13),
					A(4) => input_vector(12),
					A(3) => input_vector(11),
					A(2) => input_vector(10),
					A(1) => input_vector(9),
					A(0) => input_vector(8),
					B(7) => input_vector(7),
					B(6) => input_vector(6),
					B(5) => input_vector(5),
					B(4) => input_vector(4),
					B(3) => input_vector(3),
					B(2) => input_vector(2),
					B(1) => input_vector(1),
					B(0) => input_vector(0),
					
					Cout => output_vector(8),
					S(7) => output_vector(7),
					S(6) => output_vector(6),
					S(5) => output_vector(5),
					S(4) => output_vector(4),
					S(3) => output_vector(3),
					S(2) => output_vector(2),
					S(1) => output_vector(1),
					S(0) => output_vector(0));
end DutWrap;

