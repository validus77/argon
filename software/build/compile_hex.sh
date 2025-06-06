#!/bin/bash

# Check if at least one file is provided
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 [-o output_file] <file1> <file2> ... <fileN>"
    exit 1
fi

# Check if the -o option is given
if [ "$1" == "-o" ]; then
    # If -o option is provided, set output file
    if [ "$#" -lt 3 ]; then
        echo "Usage: $0 [-o output_file] <file1> <file2> ... <fileN>"
        exit 1
    fi
    output_file="$2"
    shift 2  # Shift to leave only file arguments
    #riscv64-unknown-elf-gcc -mabi=ilp32 -march=rv32i -nostartfiles -nostdlib -T ../libs/linker.ld -o "$output_file" "$@"
    riscv64-unknown-elf-gcc -I/usr/lib/gcc/riscv64-unknown-elf/10.2.0/include/ -mabi=ilp32 -march=rv32i -O0 -nostartfiles -nostdlib -mno-strict-align -mcmodel=medany -fno-builtin -T ../libs/linker.ld -o "$output_file" ../libs/start.s "$@" -lgcc
else
    # No -o option provided, use default output (a.out)
    output_file="a.out"
    riscv64-unknown-elf-gcc -I/usr/lib/gcc/riscv64-unknown-elf/10.2.0/include/ -mabi=ilp32 -march=rv32i -nostartfiles -nostdlib -T ../libs/linker.ld ../libs/start.s "$@" -lgcc
fi

# Generate a temporary .bin file
temp_bin_file=$(mktemp "${output_file}.XXXXXX.bin")

# Convert the object file to binary
riscv64-unknown-elf-objcopy -O binary "$output_file" "$temp_bin_file"
#riscv64-unknown-elf-objcopy -O verilog "$output_file" "$output_file".hex

# Convert the binary file to a hex file
xxd -p "$temp_bin_file" > "${output_file}.hex"
../build/format_hex.py "${output_file}.hex"
#clean up 
rm -f "$output_file"
rm -f "$temp_bin_file"

# Notify user
echo "Hex file generated: ${output_file}.hex"