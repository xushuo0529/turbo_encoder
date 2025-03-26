--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: RSC_encoder.vhd
-- File history:
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--
-- Description: 
--
-- <Description here>
--
-- Targeted device: <Family::PolarFire> <Die::MPF300T> <Package::FCG484>
-- Author: <Name>
--
--------------------------------------------------------------------------------

-- File: rsc_encoder.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RSC_encoder is
port(
    clk      : in  std_logic;
    rstn    : in  std_logic;
    data_in  : in  std_logic;
	terminated : in STD_LOGIC;
    encoded_output : out STD_LOGIC_VECTOR(1 downto 0)
);
end RSC_encoder;

architecture Behavioral of RSC_encoder is
    --signal shift_reg : STD_LOGIC_VECTOR(2 downto 0) := "000";
	signal shift_reg : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal feedback : STD_LOGIC := '0';
	signal din_1    : STD_LOGIC := '0';

    signal output_bits : STD_LOGIC_VECTOR(1 downto 0); -- Output bits for encoding
begin

	-- feedback <= shift_reg(2) xor shift_reg(1);
	feedback <= shift_reg(2) xor shift_reg(3);
	din_1 <=data_in xor feedback; 	
	process(clk,rstn)
    begin
	    if (rstn = '0') then
			-- shift_reg <= "000"; 
			shift_reg <= "0000";
			output_bits(1) <='0';
			output_bits(0) <='0';
		elsif (rising_edge(clk)) then
		    -- shift_reg<=shift_reg(1 downto 0)& din_1;
			shift_reg<=shift_reg(2 downto 0)& din_1;
			output_bits(1) <= data_in;
			-- output_bits(0) <=  din_1 xor shift_reg(0) xor shift_reg(2);
			output_bits(0) <=  din_1 xor shift_reg(0) xor shift_reg(2) xor shift_reg(3);
		end if;
	end process;		
	
	encoded_output <= output_bits; 
	
end Behavioral;