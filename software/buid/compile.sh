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
    riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -nostartfiles -nostdlib -T ../libs/linker.ld -o "$output_file" ../libs/start.s "$@"
else
    # No -o option provided, use default output (a.out)
    riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -nostartfiles -nostdlib  -T ../libs/linker.ld ../libs/start.s "$@"
fi