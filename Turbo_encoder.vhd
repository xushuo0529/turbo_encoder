--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: Turbo_encoder.vhd
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
--1/3turbo编码器
library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;  -- 添加数值转换库
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Turbo_encoder is
port (
	clk			: IN  std_logic;
	rstn		: IN  std_logic;
	data_in 	: IN  std_logic; 
	data_in_vd 	: IN  std_logic;
	
    data_out 	: OUT std_logic  
);
end Turbo_encoder;
architecture architecture_Turbo_encoder of Turbo_encoder is

	signal wr_adr,wr_adr_reg0 : std_logic_vector(13 downto 0) ;
	signal address_in,address_out0,address_out1 : std_logic_vector(13 downto 0) ;
	signal cnt_wr,cnt_rd:integer range 0 to 16383;
	signal data_in_d0,data_in_d1,data_in_vd_d0,data_in_vd_d1: std_logic:='0';
	signal wr_en,wr_en_reg0,rd_en,rd_en_reg0,rd_en_reg1: std_logic:='0';
	signal rsc_data_in0,rsc_data_in0_d0,rsc_data_in0_d1: std_logic;
	signal rsc_data_in1,rsc_data_in1_d0,rsc_data_in1_d1: std_logic;
	signal data_init: std_logic;
	signal asm : std_logic_vector(95 downto 0) :=X"25D5C0CE8990F6C9461BF79C"; 
	signal encoder_out: std_logic_vector(2 downto 0) ;
	-- 双缓冲控制信号 --------------------------------------------------------
	signal ram_block_sel     : std_logic := '0';  -- 当前写入块选择（0=Block0,1=Block1）
	signal wr_base_addr      : std_logic_vector(14 downto 0) := (others => '0');
	signal rd_base_addr      : std_logic_vector(14 downto 0) := (others => '0');
	
	-- 地址生成信号 ------------------------------------------------------
	signal ram_wr_addr_full,ram_rd_addr_full_0, ram_rd_addr_full_1:std_logic_vector(14 downto 0);	
	
	component RSC_encoder 
	port(
    clk      		: in  std_logic;
    rstn    		: in  std_logic;
    data_in  		: in  std_logic;
	start_flag 		: in STD_LOGIC;
    encoded_output 	: out STD_LOGIC_VECTOR(1 downto 0)
	);
	end component;
	
	COMPONENT Index_rom
	port(
	clk 			: IN std_logic;
	rstn			: IN std_logic;
	data_ready 	: IN  std_logic;
	address_in 	: in std_logic_vector(13 downto 0)  ;
	address_out0 	: out std_logic_vector(13 downto 0) ;
	address_out1 	: out std_logic_vector(13 downto 0) ;
	index_end_flag 	: out  std_logic	
	);
	END COMPONENT;
	
	COMPONENT PF_RAM_17840
	PORT(
	  R_ADDR 	: in std_logic_vector(14 downto 0)  ;
	  R_CLK 	: in  std_logic;
	  R_EN 		: in  std_logic;
	  W_ADDR 	: in std_logic_vector(14 downto 0)  ;
	  W_CLK		: in  std_logic;
	  W_DATA	: in  std_logic;
	  W_EN		: in  std_logic;
	  --Outputs   
	  R_DATA	: out  std_logic
	  );
	END COMPONENT;
begin

	process(clk)
	begin  
	  if (rising_edge (clk))then
	  data_in_d0<=data_in;
	  data_in_d1<=data_in_d0;
	  
	  data_in_vd_d0<=data_in_vd;
	  data_in_vd_d1<=data_in_vd_d0;
	  end if;	
	end process;
	

	
	
	process(clk,rstn)
	begin               
		if(rstn='0')then
			cnt_wr<=0;
			wr_en<='0';
			rd_en<='0';
			wr_adr<=(others=>'0');
	    elsif(rising_edge(clk))then
			if (data_in_vd_d0='1' )then 
				if ( cnt_wr = 8919) then
					cnt_wr <= 0;
					rd_en <= '1';       -- 开启读使能
					wr_adr <= (others => '0');
					
				else
					cnt_wr<=cnt_wr+1;
					wr_adr<=wr_adr+'1';					
				end if;
					wr_en <= '1';
			end if;
		end if;
	end process;
	
	process(clk,rstn)
	begin               
		if(rstn='0')then
			ram_block_sel <= '0';
		elsif(rising_edge(clk))then
			if ( ram_wr_addr_full=X"22D6" or ram_wr_addr_full=X"45AE") then
				ram_block_sel <= not ram_block_sel;  -- 切换写入块
			end if;
		end if;
	end process;
	
	process(clk,rstn)
	begin   
		if(rstn='0')then
		    rd_en_reg0<='0';
			rd_en_reg1<='0';
		elsif(rising_edge(clk))then
			rd_en_reg0<=rd_en;
			rd_en_reg1<=rd_en_reg0;
		end if;
	end process;
	
	process(clk)
	begin   
	   if(rising_edge(clk))then
	       if (ram_block_sel = '0')then
				rd_base_addr <= "010001011011000";
		   else
			    rd_base_addr<="000000000000000";  
		   end if;
		end if;
	end process;
	   
	
	-- 物理地址生成逻辑 ------------------------------------------------------
	wr_base_addr <= "000000000000000" when ram_block_sel = '0' else 
                "010001011011000";  -- Block0:0-8919, Block1:8920-17839
	--rd_base_addr <= "010001011011000" when ram_block_sel = '0' else 
                --"000000000000000";  
	
	process(clk, rstn)
	begin	
		if (rstn = '0') then  
		ram_wr_addr_full<= (others => '0');
		ram_rd_addr_full_0<= (others => '0');
		ram_rd_addr_full_1<= (others => '0');
		elsif (rising_edge(clk)) then
		ram_wr_addr_full <= std_logic_vector(unsigned(wr_base_addr) + unsigned(wr_adr));
		ram_rd_addr_full_0<=std_logic_vector(unsigned(rd_base_addr) + unsigned(address_out0));
		ram_rd_addr_full_1<=std_logic_vector(unsigned(rd_base_addr) + unsigned(address_out1));
		end if;
	end process;
	process(clk, rstn)
	begin
    if (rstn = '0' or rd_en='0') then  
        address_in <= (others => '0');
    elsif (rising_edge(clk) and rd_en='1') then
        -- 同步逻辑：地址递增并限制范围
        if (unsigned(address_in) < 8919) then
            address_in <= std_logic_vector(unsigned(address_in) + 1);
        else
            address_in <= (others => '0');  -- 循环计数
        end if;
    end if;
	end process;
  

		inst_RAM_1:PF_RAM_17840
		port map(
		R_ADDR 	=>ram_rd_addr_full_0,
		R_CLK 	=>clk,
		R_EN 	=>rd_en_reg1,	
		W_ADDR 	=>ram_wr_addr_full,
		W_CLK	=>clk,	
		W_DATA	=>data_in_d1,
		W_EN	=>wr_en,
		R_DATA	=>rsc_data_in0
		);
		
		inst_RAM_2:PF_RAM_17840
		port map(
		R_ADDR 	=>ram_rd_addr_full_1,
		R_CLK 	=>clk,
		R_EN 	=>rd_en_reg1,	
		W_ADDR 	=>ram_wr_addr_full,
		W_CLK	=>clk,	
		W_DATA	=>data_in_d1,
		W_EN	=>wr_en,
		R_DATA	=>rsc_data_in1
		);

		inst_index_rom :Index_rom
		port map(
		clk				=> clk,
		rstn			=>rstn,
		data_ready		=>rd_en,
		address_in		=> address_in,
		address_out0	=>address_out0,
		address_out1	=>address_out1,
		index_end_flag	=>open
		);
		
		inst_RSC_encoder1:RSC_encoder
		port map(
		clk    			=> clk,  		
		rstn   			=>rstn, 		
		data_in  		=>rsc_data_in0,	
		start_flag 		=>	rd_en,
		encoded_output  =>encoder_out(2 downto 1)
		);
		inst_RSC_encoder2:RSC_encoder
		port map(
		clk    			=> clk,  		
		rstn   			=>rstn, 		
		data_in  		=>rsc_data_in1,	
		start_flag 		=>rd_en,
		encoded_output(1)=> data_init,
		encoded_output(0)  =>encoder_out(0)
		);

   -- architecture body
end architecture_Turbo_encoder;
