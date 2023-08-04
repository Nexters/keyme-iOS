#!/bin/bash

KEY_PATH="Tuist/master.key"

ENCRYPTED_DIR="Encrypted"
SECRET_DIR="Secrets"

OUTPUT_DIR="Projects/Keyme/Resources/Secrets"
XCCONFIG_APP_DIR="XCConfig/App"
XCCONFIG_TARGET_DIR="XCConfig/Target"

# Find all non-hidden files in the secrets directory that don't have the .encrypted extension
files=($(find ${OUTPUT_DIR} -type f ! -name ".*" ! -name "*.encrypted"))
xcconfigAppFiles=($(find ${XCCONFIG_APP_DIR} -type f ! -name ".*" ! -name "*.encrypted"))
xcconfigTargetFiles=($(find ${XCCONFIG_TARGET_DIR} -type f ! -name ".*" ! -name "*.encrypted"))

allFiles=("${files[@]}" "${xcconfigAppFiles[@]}" "${xcconfigTargetFiles[@]}" )

# Loop through the array and encrypt each file
for file in "${allFiles[@]}"
do
   # Extract the filename from the file path
   filename=$(basename $file)

   if [[ $file == *"$XCCONFIG_APP_DIR"* ]]; then
        out_dir="${XCCONFIG_APP_DIR}"
   elif [[ $file == *"$XCCONFIG_TARGET_DIR"* ]]; then
        out_dir="${XCCONFIG_TARGET_DIR}"
   else
        out_dir="${SECRET_DIR}"
   fi

   # Create the output file path by appending the filename to the output directory
   out_file="${ENCRYPTED_DIR}/${out_dir}/${filename}.encrypted"

   openssl enc -aes-256-cbc -nosalt -in $file -out $out_file -pass file:${KEY_PATH}
done
