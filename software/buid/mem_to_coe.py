#!/usr/bin/env python3

import argparse

def mem_to_coe(mem_file, coe_file):
    with open(mem_file, 'r') as infile, open(coe_file, 'w') as outfile:
        # Write the header for the COE file
        outfile.write("memory_initialization_radix=16;\n")
        outfile.write("memory_initialization_vector=\n")

        # Read the lines from the .mem file and write to .coe
        lines = infile.readlines()
        for i, line in enumerate(lines):
            line = line.strip()  # Remove whitespace
            if line:  # If the line is not empty
                outfile.write(line)
                if i < len(lines) - 1:
                    outfile.write(",\n")  # Add comma if not the last line
                else:
                    outfile.write(";\n")  # End the vector with a semicolon

# Main function to handle command-line arguments
def main():
    parser = argparse.ArgumentParser(description='Convert a .mem file to a .coe file format (32-bit word per line)')
    
    # Input and output file arguments
    parser.add_argument('mem_file', type=str, help='Path to the input .mem file')
    parser.add_argument('coe_file', type=str, help='Path to the output .coe file')
    
    args = parser.parse_args()
    
    # Call the conversion function with provided file paths
    mem_to_coe(args.mem_file, args.coe_file)
    print(f"Conversion complete: {args.mem_file} -> {args.coe_file}")

if __name__ == "__main__":
    main()