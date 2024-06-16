#!/bin/bash

# Loop through control plane names cp_grp1 to cp_grp5
for i in {1..5}
do
  control_plane_name="cp_grp${i}"
  echo "Running command for ${control_plane_name}"
  act --input control_plane_name=${control_plane_name} \
      --input system_account=npa_platform_system_account \
      --input action=deploy \
      -W .github/workflows/deploy-dp.yaml
done