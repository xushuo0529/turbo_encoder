----------------------------------------------------------------------
-- Created by Microsemi SmartDesign Thu Mar 27 17:41:18 2025
-- Testbench Template
-- This is a basic testbench that instantiates your design with basic 
-- clock and reset pins connected.  If your design has special
-- clock/reset or testbench driver requirements then you should 
-- copy this file and modify it. 
----------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: A_tb_turbo.vhd
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

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_textio.all;
USE ieee.std_logic_arith.ALL;
use ieee.numeric_std.all;
USE ieee.std_logic_signed.ALL;
library std;
use std.textio.all;

entity A_tb_turbo is
end A_tb_turbo;

architecture behavioral of A_tb_turbo is

    constant SYSCLK_PERIOD : time := 100 ns; -- 10MHZ
    constant clk20m_period : time := 50 ns;
	signal clk20m,rstn:std_logic:='0';
	signal data_test,data_vd:std_logic:='0';
	--FILE infile:text is in "ccsds_data.txt";  


    component Turbo_encoder
        -- ports
        port( 
            -- Inputs
            clk : in std_logic;
            rstn : in std_logic;
            data_in : in std_logic;
            data_in_vd : in std_logic;

            -- Outputs
            data_out : out std_logic

            -- Inouts

        );
    end component;

begin

    rstn_gen :process
    begin 
		rstn  <= '0';
		wait for clk20m_period*10  ;
		rstn  <= '1';
		wait for clk20m_period*50000;
    end process;

	
   clk20m_process :process
   begin
		clk20m <= '0';
		wait for clk20m_period/2;
		clk20m <= '1';
		wait for clk20m_period/2;
   end process;
   
   process
	variable li:line;
	variable dat0:std_logic;
	file infile : text open read_mode is "ccsds_data.txt"; 	
	begin
	wait for 1000 ns;
		data_vd<='1';
	while true loop
        -- 检查并维持文件打开状态
        if endfile(infile) then
            file_close(infile);
            file_open(infile, "ccsds_data.txt", read_mode);
        end if;

        -- 读取并输出数据
        readline(infile, li);
        read(li, dat0);
        data_test <= dat0;
        
        -- 固定间隔50ns（无无效周期）
        wait for 50 ns;
    end loop;
    
   -- wait;
end process;
   
    -- process
	-- variable li:line;
	-- variable dat0:std_logic;
	-- file infile : text open read_mode is "ccsds_data.txt"; 	
	-- begin
	-- wait for 1000 ns;
		-- data_vd<='1';
	    -- while not(endfile(infile))loop
		     -- readline(infile,li);
			      -- read(li,dat0);
					
					-- data_test <=dat0;
					-- wait for 50 ns;
       -- end loop;		
	   
    -- end process;
   
    Turbo_encoder_0 : Turbo_encoder
        -- port map
        port map( 
            -- Inputs
            clk => clk20m,
            rstn => rstn,
            data_in => data_test,
            data_in_vd => data_vd,

            -- Outputs
            data_out => open

            -- Inouts

        );
		

end behavioral;

