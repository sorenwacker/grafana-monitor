#!/bin/bash

# Get a list of all running instances
instances=$(apptainer instance list | awk 'NR>1 {print $1}')

# Check if there are any running instances
if [ -z "$instances" ]; then
  echo "No running instances found."
  exit 0
fi

# Loop through each instance and stop it
for instance in $instances; do
  echo "Stopping instance: $instance"
  apptainer instance stop "$instance"
  if [ $? -ne 0 ]; then
    echo "Failed to stop instance: $instance"
  fi
done

echo "All running instances have been stopped."

