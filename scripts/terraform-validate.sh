#!/usr/bin/env bash
set -euo pipefail

mapfile -t dirs < <(find . -name '*.tf' -not -path '*/.terraform/*' -exec dirname {} \; | sort -u)

for dir in "${dirs[@]}"; do
  echo "==> ${dir}"
  terraform -chdir="${dir}" init -backend=false -input=false
  terraform -chdir="${dir}" validate
done
