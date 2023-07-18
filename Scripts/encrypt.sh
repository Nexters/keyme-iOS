#!/bin/bash

KEY_PATH="Tuist/master.key"
SECRETS_DIR="Targets/Keyme/Encrypted"
OUTPUT_DIR="Targets/Keyme/Resources/Secrets"

# Find all non-hidden files in the secrets directory that don't have the .encrypted extension
files=($(find ${OUTPUT_DIR} -type f ! -name ".*" ! -name "*.encrypted"))

# Loop through the array and encrypt each file
for file in "${files[@]}"
do
   # Extract the filename from the file path
   filename=$(basename $file)

   # Create the output file path by appending the filename to the output directory
   out_file="${SECRETS_DIR}/${filename}.encrypted"

   openssl enc -aes-256-cbc -nosalt -in $file -out $out_file -pass file:${KEY_PATH}
done
