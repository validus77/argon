#!/usr/bin/env python3

import argparse

# Convert hex file to mem format (32-bit word per line)
def hex_to_mem(hex_file, mem_file):
    with open(hex_file, 'r') as infile, open(mem_file, 'w') as outfile:
        hex_data = infile.read().strip()  # Read the entire hex data
        # Group the data into 32-bit (8 hex chars = 4 bytes)
        for i in range(0, len(hex_data), 8):
            word = hex_data[i:i+8]         # Extract 32-bit word
            outfile.write(f"{word}\n")     # Write to .mem file

# Main function to handle command-line arguments
def main():
    parser = argparse.ArgumentParser(description='Convert a .hex file to a .mem file format (32-bit word per line)')
    
    # Input and output file arguments
    parser.add_argument('hex_file', type=str, help='Path to the input .hex file')
    parser.add_argument('mem_file', type=str, help='Path to the output .mem file')
    
    args = parser.parse_args()
    
    # Call the conversion function with provided file paths
    hex_to_mem(args.hex_file, args.mem_file)
    print(f"Conversion complete: {args.hex_file} -> {args.mem_file}")

if __name__ == "__main__":
    main()