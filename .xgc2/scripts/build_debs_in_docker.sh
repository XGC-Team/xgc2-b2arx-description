#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

DOCKER_IMAGE="${DOCKER_IMAGE:-ros:jazzy-ros-base-noble}"
WORK_DIR="${WORK_DIR:-${REPO_ROOT}/.work/docker}"
OUTPUT_DIR="${OUTPUT_DIR:-${REPO_ROOT}/debs}"
INSTALL_CHECK="${INSTALL_CHECK:-true}"
EXPECTED_ARCH="${EXPECTED_ARCH:-}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --image)
      DOCKER_IMAGE="$2"
      shift 2
      ;;
    --work-dir)
      WORK_DIR="$2"
      shift 2
      ;;
    --output-dir)
      OUTPUT_DIR="$2"
      shift 2
      ;;
    --skip-install-check)
      INSTALL_CHECK=false
      shift
      ;;
    *)
      echo "unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

mkdir -p "${WORK_DIR}" "${OUTPUT_DIR}"

docker pull "${DOCKER_IMAGE}"
docker run --rm -e XGC2_APT_OVERLAY_URL="${XGC2_APT_OVERLAY_URL:-}" -e DEBIAN_FRONTEND=noninteractive -e EXPECTED_ARCH="${EXPECTED_ARCH}" -e INSTALL_CHECK="${INSTALL_CHECK}" -v "${REPO_ROOT}:/workspace/repo:ro" -v "${WORK_DIR}:/workspace/work" -v "${OUTPUT_DIR}:/workspace/out" "${DOCKER_IMAGE}" bash -lc '
    set -euo pipefail

    export DEBIAN_FRONTEND=noninteractive
    actual_arch="$(dpkg --print-architecture)"
    if [[ -n "${EXPECTED_ARCH}" && "${actual_arch}" != "${EXPECTED_ARCH}" ]]; then
      echo "container architecture ${actual_arch} != expected ${EXPECTED_ARCH}" >&2
      exit 1
    fi

    apt-get update
    apt-get install -y --no-install-recommends build-essential cmake dpkg-dev fakeroot file python3 python3-colcon-common-extensions python3-pytest rsync ros-jazzy-ament-cmake ros-jazzy-ament-cmake-pytest ros-jazzy-ros2pkg ros-jazzy-urdf

    rm -rf /workspace/work/build /workspace/work/install /workspace/work/install-root /workspace/work/log /workspace/work/src /workspace/work/stage-build
    mkdir -p /workspace/work/src/b2arx_description
    rsync -a --delete /workspace/repo/ /workspace/work/src/b2arx_description/

    cd /workspace/work
    set +u
    source /opt/ros/jazzy/setup.bash
    set -u
    colcon build --packages-select b2arx_description --cmake-args -DBUILD_TESTING=ON
    colcon test --packages-select b2arx_description
    colcon test-result --verbose
    cmake -S /workspace/work/src/b2arx_description -B /workspace/work/stage-build -DCMAKE_INSTALL_PREFIX=/opt/ros/jazzy -DBUILD_TESTING=OFF
    DESTDIR=/workspace/work/install-root cmake --build /workspace/work/stage-build --target install

    /workspace/repo/.xgc2/scripts/package_debs.sh --install-root /workspace/work/install-root --output-dir /workspace/out

    if [[ "${INSTALL_CHECK}" == "true" ]]; then
      apt-get install -y /workspace/out/ros-jazzy-xgc2-b2arx-description_*.deb
      env -i PATH=/usr/bin:/bin /bin/bash --noprofile --norc /workspace/repo/.xgc2/scripts/check_installed_packages.sh
    fi
  '

echo "Debian package output:"
find "${OUTPUT_DIR}" -maxdepth 1 -type f -name "*.deb" -print | sort
