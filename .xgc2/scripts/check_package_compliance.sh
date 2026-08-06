#!/usr/bin/env bash
set -euo pipefail

grep -q '^id: xgc2-b2arx-description$' .xgc2/product.yml
grep -q '^version: 0.1.0$' .xgc2/product.yml
grep -q '<name>b2arx_description</name>' package.xml
test -f urdf/b2arx_visual.urdf
test -f meshes/base_link.dae
test -f meshes/link1.STL
grep -q 'robot name="b2arx"' urdf/b2arx_visual.urdf
grep -q 'package://b2arx_description/meshes/' urdf/b2arx_visual.urdf
grep -q 'R5a_joint1' urdf/b2arx_visual.urdf
grep -q 'b2_description_FL_hip_joint' urdf/b2arx_visual.urdf
# no relative mesh paths left
if grep -E 'filename="meshes/' urdf/b2arx_visual.urdf; then
  echo "relative mesh paths remain" >&2
  exit 1
fi
# product must not hardcode host USB/CAN
if grep -ERi 'enP2p1s0|2207:0019|slcan1|192\.168\.123' urdf package.xml CMakeLists.txt README.md; then
  echo "hardcoded machine topology found" >&2
  exit 1
fi

echo "Package compliance checks passed."
