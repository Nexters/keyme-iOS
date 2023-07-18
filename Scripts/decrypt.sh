#!/bin/bash

KEY_PATH="Tuist/master.key"
SECRETS_DIR="Targets/Keyme/Encrypted"
OUTPUT_DIR="Targets/Keyme/Resources/Secrets"

# Find all encrypted files in the secrets directory
files=($(find ${SECRETS_DIR} -type f -name "*.encrypted"))

# Loop through the array and decrypt each file
for file in "${files[@]}"
do
   # Extract the filename from the file path
   filename=$(basename $file .encrypted)

   # Create the output file path by appending the filename to the output directory
   out_file="${OUTPUT_DIR}/${filename}"

   # Only decrypt if the normal file does not exist
   if [ ! -f "$out_file" ]; then
      openssl enc -d -aes-256-cbc -nosalt -in $file -out $out_file -pass file:${KEY_PATH}
   fi
done
