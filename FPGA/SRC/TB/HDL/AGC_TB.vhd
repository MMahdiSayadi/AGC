----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/01/2024 04:48:45 PM
-- Design Name: 
-- Module Name: AGC_TB - Behavioral
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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity AGC_TB is
--  Port ( );
end AGC_TB;

architecture Behavioral of AGC_TB is

-- =============================================================================================
-- TYPE DECLERATION 
-- =============================================================================================
	TYPE STR_ARRAY_RD IS ARRAY ( NATURAL RANGE <> ) OF STRING( 1 TO 26 );
	TYPE STD_ARRAY_32 IS ARRAY ( NATURAL RANGE <> ) OF STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	
-- =============================================================================================
-- SIGNAL DECLERATION 
-- =============================================================================================	
	
	-- Inst_FileReaderv_1
		Signal s_Clk				: STD_LOGIC := '0'; 
		Signal s_Reset			: STD_LOGIC := '0'; 
		Signal s_rd_tdata 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 ) := ( Others => '0' );
		Signal s_rd_tvalid 		: STD_LOGIC := '0';
		Signal s_nlms_tvalid 		: STD_LOGIC := '0';
		
	-- Inst_AGC
		Signal s_targetStep_tvalid 	: STD_LOGIC := '0';
		
		
	-- fileNames	
		Signal s_rd_names 	: STR_ARRAY_RD( 0 TO 1 ) := 
			(
				"Mat_Out_INPSIG_00_Real.txt",
				"Mat_Out_INPSIG_00_Imag.txt"
			);
		
	
	
begin





	Inst_FileReaderv_1 : Entity Work.FileReaderv_1 
		GENERIC MAP 
			(
				G_interval				=> 36,
				G_data_width 				=> 32,
				G_half_width 				=> 16, 
				G_data_len	 			=> 5120,
				real_file_name_addr 		=> s_rd_names(0),
				imag_file_name_addr 		=> s_rd_names(1)
			)
		PORT MAP 
			(
				i_Clk   					=> s_Clk,
				i_Reset 					=> s_Reset,
				o_ax_1_data_tdata   		=> s_rd_tdata,
				o_ax_1_data_tvalid  		=> s_rd_tvalid
			);
	
	
	Inst_AGC : Entity Work.AGC 
		PORT MAP 
			(
				i_Clk 				=> s_Clk,
				i_din_tdata 			=> s_rd_tdata,
				i_din_tvalid 			=> s_rd_tvalid,
				targetLevel			=> X"00C8",
				o_dout_tdata 			=> OPEN, 
				o_dout_tvalid 		=> OPEN 
			);
	
	
	
	
	s_targetStep_tvalid <= '1';
	s_Clk 	<= NOT s_Clk AFTER 3ns;
	s_Reset	<= '1', '0' AFTER 500ns;



end Behavioral;
