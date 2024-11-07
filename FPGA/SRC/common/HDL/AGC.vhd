----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/01/2024 01:03:55 PM
-- Design Name: 
-- Module Name: AGC - Behavioral
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

entity AGC is
	PORT 
		(
			i_Clk 				: IN STD_LOGIC;
			i_din_tdata 			: IN STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			i_din_tvalid 			: IN STD_LOGIC;
			targetLevel			: IN STD_LOGIC_VECTOR( 15 DOWNTO 0 ); -- fixed(16, 0 )
			o_dout_tdata 			: OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			o_dout_tvalid 		: OUT STD_LOGIC
		);
end AGC;

architecture Behavioral of AGC is

-- =====================================================================================
-- CONSTANT AND TYPE DECLERATION 
-- =====================================================================================

	CONSTANT stepSize 	: STD_LOGIC_VECTOR( 31 DOWNTO 0 ) := X"00000432";

-- =====================================================================================
-- SIGNAL DECLERATION 
-- =====================================================================================
	
	-- INPUT_REGISTER_PROCESS
		Signal s_targetLevel				: STD_LOGIC_VECTOR( 15 DOWNTO 0 ) := ( Others => '0' );
		Signal s_stepSize					: STD_LOGIC_VECTOR( 31 DOWNTO 0 ) := ( Others => '0' );
		Signal s_dataI_tdata 				: STD_LOGIC_VECTOR( 15 DOWNTO 0 ) := ( Others => '0' );
		Signal s_dataQ_tdata 				: STD_LOGIC_VECTOR( 15 DOWNTO 0 ) := ( Others => '0' );
		Signal s_data_tvalid 				: STD_LOGIC_VECTOR( 15 DOWNTO 0 ) := ( Others => '0' );
		
	-- Inst_gainInjector_real
		Signal s_Gain						: SIGNED( 31 DOWNTO 0 ) := B"00000000100000000000000000000000";
		Signal s_feedback_re_tdata 			: STD_LOGIC_VECTOR( 15 DOWNTO 0 ) := ( Others => '0' );
	
	-- Inst_gainInjector_imag
		Signal s_feedback_im_tdata 			: STD_LOGIC_VECTOR( 15 DOWNTO 0 ) := ( Others => '0' );
	
	-- Inst_abs_mult_II
		Signal s_currentLevel_re_tdata		: SIGNED( 15 DOWNTO 0 ) := ( Others => '0' );
		
	-- Inst_abs_mult_QQ	
		Signal s_currentLevel_im_tdata		: SIGNED( 15 DOWNTO 0 ) := ( Others => '0' );
		
	-- ERROR_CALCULATOR_PROCESS
		Signal s_currentLevel_tdata 		: SIGNED( 15 DOWNTO 0 ) := ( Others => '0' );
		Signal s_Error_tdata 				: SIGNED( 15 DOWNTO 0 ) := ( Others => '0' );
	
	-- Inst_ErrxStep
		Signal s_ErrxStep_tdata 			: STD_LOGIC_VECTOR( 31 DOWNTO 0 ) := ( Others => '0' );
		Signal s_reg_ErrxStep_tdata 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 ) := ( Others => '0' );
	
	
begin

INPUT_REGISTER_PROCESS : PROCESS (i_Clk) IS 
BEGIN 
	if rising_Edge (i_Clk) then 
		
		if i_din_tvalid = '1' then 
			s_dataI_tdata  <= i_din_tdata( 15 DOWNTO 0 );
			s_dataQ_tdata  <= i_din_tdata( 31 DOWNTO 16);
		end if; 
		s_data_tvalid <= s_data_tvalid( 14 DOWNTO 0 ) & i_din_tvalid; 
		
		s_targetLevel 	<= targetLevel;
		s_stepSize		<= stepSize;
		
	end if;
END PROCESS INPUT_REGISTER_PROCESS;
	
	Inst_gainInjector_real : Entity Work.gainInjector
		PORT MAP 
			(
				CLK 	=> i_Clk,
				A 	=> s_dataI_tdata,
				B 	=> STD_LOGIC_VECTOR(s_Gain),
				P 	=> s_feedback_re_tdata
			);
	
	Inst_gainInjector_imag : Entity Work.gainInjector
		PORT MAP 
			(
				CLK 	=> i_Clk,
				A 	=> s_dataQ_tdata,
				B 	=> STD_LOGIC_VECTOR(s_Gain),
				P 	=> s_feedback_im_tdata
			);

ERROR_CALCULATOR_PROCESS : PROCESS (i_Clk) IS 
BEGIN 
	if rising_Edge (i_Clk) then 
		
		if s_data_tvalid(5) = '1' then 
			if SIGNED(s_feedback_re_tdata) >= 0 then 
				s_currentLevel_re_tdata 	<= SIGNED(s_feedback_re_tdata);
			else 
				s_currentLevel_re_tdata 	<= -SIGNED(s_feedback_re_tdata);
			end if;
			
			if SIGNED(s_feedback_im_tdata) >= 0 then 
				s_currentLevel_im_tdata 	<= SIGNED(s_feedback_im_tdata);
			else 
				s_currentLevel_im_tdata 	<= -SIGNED(s_feedback_im_tdata);
			end if;
		end if;
		
		if s_data_tvalid(6) = '1' then 
			s_currentLevel_tdata	<= s_currentLevel_re_tdata + s_currentLevel_im_tdata;
		end if;
		
		if s_data_tvalid(7) = '1' then 
			s_Error_tdata 		<= SIGNED(s_targetLevel) - s_currentLevel_tdata;
		end if;
		
	end if;
END PROCESS ERROR_CALCULATOR_PROCESS;
	
	Inst_ErrxStep : Entity Work.ErrxStep
		PORT MAP 
			(
				CLK 	=> i_Clk,
				A 	=> s_stepSize,
				B 	=> STD_LOGIC_VECTOR(s_Error_tdata),
				P 	=> s_ErrxStep_tdata
			);
		
	
GAIN_CALC_PROCESS : PROCESS (i_Clk) IS 
BEGIN 
	if rising_Edge (i_Clk) then 
		
		s_reg_ErrxStep_tdata <= s_ErrxStep_tdata;
		if s_data_tvalid(14) = '1' then 
			s_Gain <= s_Gain + SIGNED(s_ErrxStep_tdata) + SIGNED(s_reg_ErrxStep_tdata);
		end if; 

	end if;
END PROCESS GAIN_CALC_PROCESS;

OUTPUT_REGISTER_PROCESS : PROCESS (i_Clk) IS 
BEGIN 
	if rising_Edge (i_Clk) then 
		
		if s_data_tvalid(5) = '1' then 
			o_dout_tdata 		<= s_feedback_im_tdata & s_feedback_re_tdata;	
		end if;
		o_dout_tvalid 	<= s_data_tvalid(5);
		
	end if;
END PROCESS OUTPUT_REGISTER_PROCESS;

end Behavioral;
