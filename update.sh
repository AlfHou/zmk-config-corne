#!/usr/bin/env bash
# Fetch/update all ZMK west dependencies.
# Run this after changing config/west.yml, or to update to the latest Mechboards ZMK.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
DOCKER_IMAGE="zmkfirmware/zmk-build-arm:4.1"

echo "==> Pulling Docker image ${DOCKER_IMAGE}..."
docker pull "${DOCKER_IMAGE}"

echo ""
echo "==> Running west update..."

docker run --rm \
    -v "${REPO_DIR}:/zmk-config" \
    -w /zmk-config/.zmk \
    --user "$(id -u):$(id -g)" \
    "${DOCKER_IMAGE}" \
    bash -c "west update"

echo ""
echo "==> Patching Mechboards fork: removing duplicate pillbug board definition..."
rm -rf "${REPO_DIR}/.zmk/zmk/app/boards/mechwild/pillbug"

echo ""
echo "==> Done. You can now run: PRISTINE=1 ./build.sh"
