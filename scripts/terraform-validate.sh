#!/usr/bin/env bash
# Run terraform init (no backend) and validate in every directory that contains .tf files.
set -euo pipefail

export TF_PLUGIN_CACHE_DIR="${TF_PLUGIN_CACHE_DIR:-${HOME}/.terraform.d/plugin-cache}"
mkdir -p "${TF_PLUGIN_CACHE_DIR}"

mapfile -t dirs < <(find . -name '*.tf' -not -path '*/.terraform/*' -exec dirname {} \; | sort -u)

for dir in "${dirs[@]}"; do
  echo "==> ${dir}"
  terraform -chdir="${dir}" init -backend=false -input=false
  terraform -chdir="${dir}" validate
done
