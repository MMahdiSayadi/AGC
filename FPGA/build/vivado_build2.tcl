set origin_dir "../SRC"
set proc_path "./procedures"
#User does not allow to change Block design directory
set BlockDesigndir "../SRC/common/BD"
set FPGA_part "xc7z020clg400-2"
set Board_part "digilentinc.com:arty-a7-100:part0:1.1"
set project_name "vivado"
set useBoard 0
set topmodule "system_top"
set gen_dir "../"
set top_sim_name "system_top"
set target_language "Verilog"

#include all header files 
set procfiles [glob -nocomplain -directory $proc_path *.tcl]
foreach tclfile $procfiles {
    source $tclfile
}

# creating project 
[gen_project $project_name $FPGA_part $useBoard $Board_part $gen_dir]
set_property target_language $target_language [current_project]

# add AD9361 library to the project 
set useLibs 0
if { $useLibs == 1 } { 
	set_property  ip_repo_paths  $gen_dir/library [current_project]
	update_ip_catalog
}

# read all dirs in dictionary 
set directories [glob -nocomplain -directory $origin_dir *]
set mainDirs {}
foreach dir $directories {
    set fileList [getFiles $dir]
    dict set mainDirs $dir $fileList
}

# adding hdl source files 
foreach dir $directories {
	set fileList [dict get $mainDirs $dir] 
	foreach newdir_src $fileList {
		if { ![ string match $origin_dir/TB $dir ] } {
			if {[string match $dir/HDL $newdir_src]} {
				set allvhdlfiles [glob -nocomplain -directory $newdir_src *.vhd]
				set allverilogfils [glob -nocomplain -directory $newdir_src *.v]
				if { [llength $allvhdlfiles] != 0 } {
					set evaluated_path [subst -nocommands -nobackslashes $allvhdlfiles]
					add_files -fileset sources_1 $evaluated_path
				}
				if { [llength $allverilogfils] != 0 } {
					set evaluated_path [subst -nocommands -nobackslashes $allverilogfils]
					add_files -fileset sources_1 $evaluated_path
				}
			} 
		}
	}
} 
[set_top_module $topmodule]


# adding hdl simulation files 
foreach dir $directories {
	set fileList [dict get $mainDirs $dir] 
	foreach newdir_src $fileList {
		if { [ string match $origin_dir/TB $dir ] } {
			if {[string match $dir/HDL $newdir_src]} {
				set allvhdlfiles [glob -nocomplain -directory $newdir_src *.vhd]
				if { [llength $allvhdlfiles] != 0 } {
					set evaluated_path [subst -nocommands -nobackslashes $allvhdlfiles]
					add_files -fileset sim_1 $evaluated_path
				}
			} 
		}
	}
}
[set_top_sim $top_sim_name]



# adding ip cores to the project
foreach dir $directories {
	set fileList [dict get $mainDirs $dir]
	foreach newdir $fileList {
		if {[string match $dir/IP $newdir]} {
			set allipcorefiles [glob -nocomplain -directory $newdir *.xcix]
			if { [llength $allipcorefiles] != 0 } {
				set evaluated_path [subst -nocommands -nobackslashes $allipcorefiles]
				add_files -fileset sources_1 $evaluated_path
			}
		} 
	}
}


# adding coe cores to the project
foreach dir $directories {
	set fileList [dict get $mainDirs $dir]
	foreach newdir $fileList {
		if {[string match $dir/COE $newdir]} {
			set allcoefiles [glob -nocomplain -directory $newdir *.coe]
			if { [llength $allcoefiles] != 0 } {
				set evaluated_path [subst -nocommands -nobackslashes $allcoefiles]
				add_files -fileset sources_1 $evaluated_path
			}
		} 
	}
}

# adding XDC files to the project
foreach dir $directories {
	set fileList [dict get $mainDirs $dir]
	foreach newdir $fileList {
		if {[string match $dir/XDC $newdir]} {
			set allxdclfiles [glob -nocomplain -directory $newdir *.xdc]
			if { [llength $allxdclfiles] != 0 } {
				set evaluated_path [subst -nocommands -nobackslashes $allxdclfiles]
				add_files -fileset constrs_1 $evaluated_path
			}
		} 
	}
}


# adding TCL files of block designs to project
set tclfiles [glob -nocomplain -directory $BlockDesigndir *.tcl]
if {[string match $target_language "VHDL"]} {
		set language_suffix ".vhd"

} else {
		set language_suffix ".v"
}
# puts $tclfiles
foreach tcl_path $tclfiles {
	if { [llength $tclfiles] != 0 } {
		# Split the path
		set path_list [file split $tcl_path]
		set last_element [lindex $path_list end]
		# Remove .tcl from the name of tcl to finde block_deign name eg: design_1.tcl ----->design_1 
		set bd_name [string range $last_element 0 end-4]
		set complete_bd_name $bd_name
		append complete_bd_name ".bd"
		set complete_path_of_bd "../vivado/vivado.srcs/sources_1/bd"
		append complete_path_of_bd "/$bd_name/$complete_bd_name"
		set complete_path_of_wrapper "../vivado/vivado.srcs/sources_1/bd"
		append complete_path_of_wrapper "/$bd_name/hdl/$bd_name"
		append complete_path_of_wrapper "_wrapper"
		append complete_path_of_wrapper $language_suffix
		puts $complete_path_of_wrapper
		source $tcl_path
		make_wrapper -files [get_files $complete_path_of_bd] -top
		add_files -norecurse $complete_path_of_wrapper
		regenerate_bd_layout
		save_bd_design
		close_bd_design [get_bd_designs bd_name]
	}
}



