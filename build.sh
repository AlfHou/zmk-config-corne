#!/usr/bin/env bash
# Build ZMK firmware locally using Docker.
# Usage:
#   ./build.sh                  - build all shields
#   ./build.sh corne_left       - build a single shield
#   PRISTINE=1 ./build.sh       - force clean build (needed after toolchain changes)
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
FIRMWARE_DIR="$REPO_DIR/firmware"
DOCKER_IMAGE="zmkfirmware/zmk-build-arm:4.1"
mkdir -p "$FIRMWARE_DIR"

build_shield() {
    local board="$1"
    local shield="$2"
    local output_name="${3:-${shield}}"
    local build_dir="build/docker_${output_name}"

    echo ""
    echo "==> Building $shield ($board)..."

    local pristine_flag=""
    if [[ "${PRISTINE:-0}" == "1" ]]; then
        pristine_flag="--pristine"
    fi

    docker run --rm \
        -v "${REPO_DIR}:/zmk-config" \
        -w /zmk-config/.zmk \
        --user "$(id -u):$(id -g)" \
        "${DOCKER_IMAGE}" \
        bash -c "
            mkdir -p ~/.cmake/packages/Zephyr ~/.cmake/packages/Zephyr-sdk
            echo '/zmk-config/.zmk/zephyr/share/zephyr-package/cmake' > ~/.cmake/packages/Zephyr/zephyr_zmk
            echo '/opt/zephyr-sdk-0.16.9/cmake' > ~/.cmake/packages/Zephyr-sdk/zephyr_sdk
            west build \
                ${pristine_flag} \
                --build-dir '${build_dir}' \
                -s zmk/app \
                -b '${board}' \
                -- \
                -DSHIELD='${shield}' \
                -DZMK_CONFIG=/zmk-config/config
        "

    local uf2="${REPO_DIR}/.zmk/${build_dir}/zephyr/zmk.uf2"
    if [[ -f "$uf2" ]]; then
        cp "$uf2" "${FIRMWARE_DIR}/${output_name}.uf2"
        echo "==> Saved: firmware/${output_name}.uf2"
    else
        echo "==> WARNING: No UF2 at $uf2"
    fi
}

# If a shield is given as argument, build only that one
if [[ $# -gt 0 ]]; then
    case "$1" in
        corne_left)   build_shield nice_nano_v2 corne_left ;;
        corne_right)  build_shield nice_nano_v2 corne_right ;;
        lily58_left)  build_shield nice_nano_v2 "lily58_left nice_view_adapter nice_view_gem" lily58_left ;;
        lily58_right) build_shield nice_nano_v2 "lily58_right nice_view_adapter nice_view_gem" lily58_right ;;
        *) echo "Unknown shield: $1"; exit 1 ;;
    esac
else
    build_shield nice_nano_v2 corne_left
    build_shield nice_nano_v2 corne_right
    build_shield nice_nano_v2 "lily58_left nice_view_adapter nice_view_gem" lily58_left
    build_shield nice_nano_v2 "lily58_right nice_view_adapter nice_view_gem" lily58_right
fi

echo ""
echo "Done! Firmware files:"
ls -lh "${FIRMWARE_DIR}"/*.uf2 2>/dev/null || echo "(none found)"
