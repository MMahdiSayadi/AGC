proc getFiles {dir} {
    set fileList [glob -nocomplain -directory $dir *]
    return $fileList
}

proc gen_project { project_name FPGA_part useBoard Board_part gen_dir} {
	
	if {[file exists $gen_dir/vivado]} {
		puts "File exists."
		file delete -force $gen_dir/vivado
		create_project $project_name $gen_dir/vivado -part $FPGA_part
	} else {
		puts "File does not exist."
		create_project $project_name $gen_dir/vivado -part $FPGA_part
	}
	if { $useBoard == 1 } {
		set_property board_part $Board_part [current_project]
	}
	set_property target_language "VHDL" [current_project]
}


proc set_top_module { top_module_name } {
	set_property top $top_module_name [current_fileset] 
	update_compile_order -fileset sources_1
}

proc set_top_sim { top_sim_name } {
	set_property top $top_sim_name [get_filesets sim_1]
	set_property top_lib xil_defaultlib [get_filesets sim_1]
	update_compile_order -fileset sim_1
}


proc add_sources {} {
}


