#!/bin/bash

# Usage: PATH=/path/to/iree/build/tools:$PATH ./compile-llama.sh <target-chip> [extra flags]

set -euo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)"

readonly IREE_COMPILE="$(which iree-compile)"
readonly CHIP="$1"
WORKING_DIR=${WORKING_DIR:-${SCRIPT_DIR}}
readonly INPUT_IR="$(realpath "$2")"
if [ ! -f "$INPUT_IR" ] ; then
  echo "Input mlir file not found: ${INPUT_IR}"
  exit 1
fi

shift 2

set -x

rm -rf "${WORKING_DIR}/configurations/llama"
rm -rf "${WORKING_DIR}/intermediates/llama"
rm -rf "${WORKING_DIR}/sources/llama"
rm -rf "${WORKING_DIR}/binaries/llama"
rm -rf "${WORKING_DIR}/benchmarks/llama"

"${SCRIPT_DIR}/compile-llama-base.sh" "$IREE_COMPILE" "$CHIP" \
  "${INPUT_IR}" \
  --iree-hal-dump-executable-configurations-to="${WORKING_DIR}/configurations/llama" \
  --iree-hal-dump-executable-intermediates-to="${WORKING_DIR}/intermediates/llama" \
  --iree-hal-dump-executable-sources-to="${WORKING_DIR}/sources/llama" \
  --iree-hal-dump-executable-binaries-to="${WORKING_DIR}/binaries/llama" \
  --iree-hal-dump-executable-benchmarks-to="${WORKING_DIR}/benchmarks/llama" \
  --iree-scheduling-dump-statistics-file="${WORKING_DIR}/tmp/llama_scheduling_stats.txt" \
  --iree-scheduling-dump-statistics-format=csv \
  -o "${WORKING_DIR}/llama.vmfb" \
  "$@"

  #--iree-hal-benchmark-dispatch-repeat-count=20 \
  #--iree-hal-executable-debug-level=3 \
  #--iree-vulkan-target-triple=rdna3-unknown-linux \
  #--iree-llvmcpu-target-triple=x86_64-unknown-linux \
  #--iree-hal-cuda-llvm-target-arch=sm_80 \
  #--mlir-disable-threading \