#!/bin/bash

# Check for target directory argument
if [ $# -ne 2 ]; then
  echo "Usage: $0 <def-files-directory> <output-directory>"
  exit 1
fi

DEF_FILES_DIR="$1"
OUTPUT_DIR="$2"

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Define the definition files and their respective SIF file names
declare -A def_files=(
  ["dcgm-exporter"]="$DEF_FILES_DIR/dcgm-exporter.def"
  ["prometheus"]="$DEF_FILES_DIR/prometheus.def"
  ["grafana"]="$DEF_FILES_DIR/grafana.def"
  ["node-exporter"]="$DEF_FILES_DIR/node-exporter.def"
  ["slurm-exporter"]="$DEF_FILES_DIR/slurm-exporter.def"
)

# Loop through each definition file and build the SIF file
for service in "${!def_files[@]}"; do
  echo "Building SIF for $service from ${def_files[$service]}..."

  # Build the SIF file
  apptainer build "$OUTPUT_DIR/${service}.sif" "${def_files[$service]}"
  
  if [[ $? -ne 0 ]]; then
    echo "Failed to build SIF for $service. Exiting."
  fi

  echo "$service SIF built successfully and saved to $OUTPUT_DIR/${service}.sif."
done
