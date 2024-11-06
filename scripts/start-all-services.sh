#!/bin/bash

# Check for target directory argument
if [ $# -ne 1 ]; then
  echo "Usage: $0 <path-to-apptainer-image-directory>"
  exit 1
fi

IMAGE_DIR="$1"

# Define the container names and their respective image files and mounts
declare -A containers=(
  ["node-exporter"]="node-exporter.sif"
  ["dcgm-exporter"]="dcgm-exporter.sif"
  ["prometheus"]="prometheus.sif"
  ["grafana"]="grafana.sif"
  ["nvidida-gpu-exporter"]="nvidia-gpu-exporter.sif"
)

# Define volumes and ports for each service
declare -A volumes=(
  ["prometheus"]="./prometheus.yml:/etc/prometheus/prometheus.yml"
  ["grafana"]="./provisioning:/etc/grafana/provisioning ./grafana_db:/var/lib/grafana"
)

declare -A ports=(
  ["node-exporter"]="9100:9100"
  ["dcgm-exporter"]="9400:9400"
  ["prometheus"]="9090:9090"
  ["grafana"]="3000:3000"
  ["nvidida-gpu-exporter"]="9835:9835"
)

# Start the containers
for service in "${!containers[@]}"; do
  echo "Starting $service..."

  # Construct bind mount options
  BIND_OPTS=""
  if [[ -n ${volumes[$service]} ]]; then
    for volume in ${volumes[$service]}; do
      BIND_OPTS+=" --bind $volume"
    done
  fi

  # Add additional bindings for GPU visibility if applicable
  if [[ "$service" == "dcgm-exporter" ]]; then
    #BIND_OPTS+=" --bind /dev:/dev"
    #BIND_OPTS+=" --bind /run:/run"
    BIND_OPTS+=" --nv"  # Include the --nv option for GPU access
  fi

  # Start the Apptainer instance
  set -x
  apptainer instance start $BIND_OPTS "$IMAGE_DIR/${containers[$service]}" "$service"
  set +x 
  
  if [[ $? -ne 0 ]]; then
    echo "Failed to start $service. Exiting."
    exit 1
  fi

  # Handle port mapping manually as Apptainer doesn't have a direct port mapping feature
  if [[ -n ${ports[$service]} ]]; then
    echo "Mapping ports for $service: ${ports[$service]}"
    # Note: You may need to handle port forwarding externally or in your network setup
  fi

  echo "$service started successfully."
done

echo "All containers have been started successfully."
