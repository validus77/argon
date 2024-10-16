#!/usr/bin/env python3

import argparse
import os
import sys

def reformat_file(file_path, chunk_size=8):
    """
    Reads a hexadecimal string from the file, splits it into chunks of chunk_size,
    reverses byte order for each chunk, and writes the chunks back to the same file,
    one per line.

    :param file_path: Path to the text file containing the hexadecimal string.
    :param chunk_size: Number of characters per chunk (default is 8).
    """
    try:
        # Read the entire content of the file
        with open(file_path, 'r') as f:
            content = f.read()
        
        # Remove any whitespace characters (spaces, newlines, etc.)
        hex_string = ''.join(content.split())
        
        # Ensure the hex string has a length that's a multiple of chunk_size
        if len(hex_string) % chunk_size != 0:
            print(f"Warning: The length of the hex string ({len(hex_string)}) is not a multiple of {chunk_size}.")
            # Optionally, pad the string with zeros to make it a multiple of chunk_size
            hex_string = hex_string.ljust(len(hex_string) + (chunk_size - len(hex_string) % chunk_size), '0')
            print(f"Padded the hex string to length {len(hex_string)}.")
        
        # Split the string into chunks of chunk_size
        chunks = [hex_string[i:i+chunk_size] for i in range(0, len(hex_string), chunk_size)]
        
        # Reverse byte order for each chunk
        reversed_chunks = []
        for chunk in chunks:
            if len(chunk) != chunk_size:
                print(f"Warning: Chunk '{chunk}' is not {chunk_size} characters long. Skipping byte reversal.")
                reversed_chunks.append(chunk)
                continue
            # Split into bytes
            byte0 = chunk[0:2]
            byte1 = chunk[2:4]
            byte2 = chunk[4:6]
            byte3 = chunk[6:8]
            # Reverse byte order
            reversed_chunk = byte3 + byte2 + byte1 + byte0
            reversed_chunks.append(reversed_chunk)
        
        # Join the reversed chunks with newline characters
        formatted_content = '\n'.join(reversed_chunks)
        
        # Write the formatted content back to the same file
        with open(file_path, 'w') as f:
            f.write(formatted_content)
        
        print(f"Successfully reformatted and reversed endianness of the file '{file_path}' with {chunk_size}-character chunks per line.")
    
    except FileNotFoundError:
        print(f"Error: The file '{file_path}' does not exist.")
    except PermissionError:
        print(f"Error: Permission denied when trying to write to '{file_path}'.")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")

# Main function to handle command-line arguments
def main():
    parser = argparse.ArgumentParser(description='Convert a .hex file to 32bit word alined format)')
    
    # Input and output file arguments
    parser.add_argument('hex_file', type=str, help='Path to the input .hex file')
    
    args = parser.parse_args()
    
    # Call the conversion function with provided file paths
    reformat_file(args.hex_file)
    print(f"Conversion complete of: {args.hex_file}")

if __name__ == "__main__":
    main()