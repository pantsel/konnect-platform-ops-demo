#!/bin/bash

# Function to print usage information
usage() {
  echo "Usage: $0 -i <input_file> -o <output_file>"
  exit 1
}

# Parse the flags
while getopts "i:o:" flag; do
  case "${flag}" in
    i) input_file="${OPTARG}" ;;
    o) output_file="${OPTARG}" ;;
    *) usage ;;
  esac
done

# Check if both input_file and output_file are set
if [ -z "${input_file}" ] || [ -z "${output_file}" ]; then
  usage
fi

# Run jq command with the input and output files
jq '.paths |= with_entries(
  .value.post |= (.["x-kong-plugin-request-validator"] = { "enabled": true }) 
  | .value.put |= (.["x-kong-plugin-request-validator"] = { "enabled": true })
)' "$input_file" > "$output_file"