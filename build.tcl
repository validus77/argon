# build.tcl

#set device_family "Artix"
set device_family "Kintex"

# Set project variables
set project_name "ArgonSoC"
set top_module "argon_soc"
set source_dir "./src"
set constraint_file "./board/board_pins.xdc" 

if { $device_family eq "Kintex" } {
    set constraint_file "./board/board_pins_kintex.xdc"
    set fpga_chip "xc7k325t-FFG676-2"
} else {
    set constraint_file "./board/board_pins_artix.xdc"
    set fpga_chip "xc7a100tfgg676-1"
}


# Create a new project
create_project $project_name ./build -part $fpga_chip -force

# Add all .sv files from the source directory
set source_files [glob -nocomplain $source_dir/*.sv]
foreach file $source_files {
    add_files $file
}



# Add constraints file
add_files $constraint_file -fileset constrs_1

# Set the top module
set_property top $top_module [current_fileset]

# Run synthesis
synth_design -top $top_module

# Run implementation
opt_design
place_design
route_design

# Generate bitstream
write_bitstream ./build/$project_name.bit

# Exit Vivado
exit
