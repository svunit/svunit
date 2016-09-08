library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity vhd_e is 
port (
  A, B: in STD_LOGIC;
  C : out STD_LOGIC
);
end vhd_e;


architecture vhd_a of vhd_e is
begin
  C <= A and B;
end vhd_a;
