----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/06/2021 07:30:57 PM
-- Design Name: 
-- Module Name: FileReaderv_1v_1 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------



library IEEE;
library work;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FileReaderv_1 is
	GENERIC 
		(
			G_interval				: INTEGER := 2;
			G_data_width 			: INTEGER := 2;
			G_half_width 			: INTEGER := 1; --this parameter is equal to G_data_width/2;
			G_data_len	 			: INTEGER := 1024; --this parameter is equal to G_data_width/2;
			real_file_name_addr 		: STRING  := "NOTHING";
			imag_file_name_addr 		: STRING  := "NOTHING"
		);
	port 
		(
			i_Clk   				: IN  STD_LOGIC;
			i_Reset 				: IN  STD_LOGIC;
			o_ax_1_data_tdata   	: OUT STD_LOGIC_VECTOR ( (G_data_width - 1) DOWNTO 0 ) := ( Others => '0' );
			o_ax_1_data_tvalid  	: OUT STD_LOGIC := '0'
	
		);
end FileReaderv_1;

architecture Behavioral of FileReaderv_1 is


-- =========================================================================
-- Signal Decleration 
-- =========================================================================
	
	Signal s_file_data_tdata	: STD_LOGIC_VECTOR( (G_data_width - 1) DOWNTO 0 ) := ( Others => '0' );
	Signal s_file_data_tvalid	: STD_LOGIC := '0';
	Signal s_interval_counter 	: INTEGER := 0;
	Signal s_data_counter 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 ) := ( Others => '0' );
	

begin

READER_PROCESS : PROCESS ( i_Clk ) IS 

	-- FILE NAME 
		file f_din_data_real   : text open read_mode is real_file_name_addr;
		file f_din_data_imag   : text open read_mode is imag_file_name_addr;
	
	-- LINE DECLERATION 
		Variable v_iline_data_real: LINE;  
		Variable v_iline_data_imag: LINE;  
		
	-- INTEGER DECLERATION 
		Variable v_std_data_real	: STD_LOGIC_VECTOR( (G_half_width - 1) DOWNTO 0 );
		Variable v_std_data_imag	: STD_LOGIC_VECTOR( (G_half_width - 1) DOWNTO 0 );

BEGIN 
	if rising_edge ( i_Clk ) then 
		if i_Reset = '1' then 
			
			s_file_data_tdata	<=	( Others => '0' );
			s_file_data_tvalid 	<= '0';
			
		else 
			
			
			if s_interval_counter < ( G_interval - 1 ) then 
			
				s_interval_counter	<=	s_interval_counter + 1;
				s_file_data_tvalid	<=	'0';
				
			else 
			
				s_interval_counter	<=	0;
				s_file_data_tvalid	<=	'1';
				-- READLINE PART 
				READLINE(f_din_data_real, v_iline_data_real);
				READLINE(f_din_data_imag, v_iline_data_imag);
				
				-- READ 
				READ(v_iline_data_real, v_std_data_real);
				READ(v_iline_data_imag, v_std_data_imag);
				
				-- DATA CONVERSION
				s_file_data_tdata( (G_half_width -1) DOWNTO 0 ) <= v_std_data_real;
				s_file_data_tdata( (G_data_width -1) DOWNTO G_half_width ) <= v_std_data_imag;
				
				if s_data_counter < G_data_len then
					s_data_counter <= s_data_counter + 1;
				end if;
				
			end if;
			
		end if;
	end if;
END PROCESS;


OUTPUT_REGISTER_PROCESS : PROCESS ( i_Clk ) IS 
BEGIN 
	if rising_edge ( i_Clk ) then 
		if i_Reset = '1' then 
			o_ax_1_data_tdata  	<=	( Others => '0' );
			o_ax_1_data_tvalid  <=	'0';
		else
			
			
			if s_data_counter < G_data_len then
				o_ax_1_data_tdata  	<=	s_file_data_tdata;
				o_ax_1_data_tvalid  <=	s_file_data_tvalid;
			else 
				o_ax_1_data_tdata  	<=	( Others => '0' );
				o_ax_1_data_tvalid  <=	'0';
			end if;
			
		end if;
	end if;
END PROCESS;


end Behavioral;
