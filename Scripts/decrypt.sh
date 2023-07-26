#!/bin/bash

KEY_PATH="Tuist/master.key"

SECRETS_DIR="Encrypted"
OUTPUT_DIR="Projects/Keyme/Resources/Secrets"

XCCONFIG_APP_DIR="XCConfig/App"
XCCONFIG_TARGET_DIR="XCConfig/Target"

# Find all encrypted files in the secrets directory
files=($(find ${SECRETS_DIR} -type f -name "*.encrypted"))

# Loop through the array and decrypt each file
for file in "${files[@]}"
do
   # Extract the filename from the file path
   filename=$(basename $file .encrypted)

   if [[ $file == *"$XCCONFIG_APP_DIR"* ]]; then
        out_dir="${XCCONFIG_APP_DIR}"
   elif [[ $file == *"$XCCONFIG_TARGET_DIR"* ]]; then
        out_dir="${XCCONFIG_TARGET_DIR}"
   else
        out_dir="${OUTPUT_DIR}"
   fi
   
   # Create the output file path by appending the filename to the output directory
   out_file="${out_dir}/${filename}"

   # Only decrypt if the normal file does not exist
   if [ ! -f "$out_file" ]; then
      openssl enc -d -aes-256-cbc -nosalt -in $file -out $out_file -pass file:${KEY_PATH}
   fi
done
