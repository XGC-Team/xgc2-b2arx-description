#!/usr/bin/env python3
"""Guard b2arx combined visual URDF structure and mesh references."""

from __future__ import annotations

import hashlib
import unittest
import xml.etree.ElementTree as ET
from pathlib import Path

PACKAGE = Path(__file__).resolve().parents[1]
URDF = PACKAGE / "urdf" / "b2arx_visual.urdf"
MESHES = PACKAGE / "meshes"
HASHES = PACKAGE / "ASSET_SHA256SUMS"


class B2ArxVisualAssetsTest(unittest.TestCase):
    def test_robot_name_and_mesh_package_uris(self) -> None:
        root = ET.parse(URDF).getroot()
        self.assertEqual(root.attrib.get("name"), "b2arx")
        meshes = root.findall(".//mesh")
        self.assertGreater(len(meshes), 10)
        for mesh in meshes:
            filename = mesh.attrib["filename"]
            self.assertTrue(
                filename.startswith("package://b2arx_description/meshes/"),
                msg=filename,
            )
            leaf = filename.rsplit("/", 1)[-1]
            self.assertTrue((MESHES / leaf).is_file(), msg=f"missing mesh {leaf}")

    def test_has_b2_and_r5a_kinematics(self) -> None:
        root = ET.parse(URDF).getroot()
        links = {e.attrib["name"] for e in root.findall("link")}
        joints = {e.attrib["name"] for e in root.findall("joint")}
        self.assertEqual(len(links), 45)
        self.assertEqual(len(joints), 44)
        self.assertIn("b2_description", links)
        self.assertIn("R5a_link1", links)
        self.assertIn("b2_description_FL_hip_joint", joints)
        self.assertIn("R5a_joint1", joints)

    def test_visual_only_boundary(self) -> None:
        root = ET.parse(URDF).getroot()
        self.assertEqual(len(root.findall(".//visual")), 22)
        for tag in ("collision", "inertial", "transmission", "gazebo", "plugin"):
            self.assertEqual(root.findall(f".//{tag}"), [], msg=tag)
        self.assertEqual(
            {child.tag for child in root},
            {"link", "joint"},
        )

    def test_required_mesh_files_exist(self) -> None:
        for name in (
            "base_link.dae",
            "FL_hip.dae",
            "FL_thigh.dae",
            "FL_calf.dae",
            "link1.STL",
            "link8.STL",
        ):
            self.assertTrue((MESHES / name).is_file(), msg=name)

    def test_asset_hash_manifest(self) -> None:
        declared = {}
        for line in HASHES.read_text(encoding="utf-8").splitlines():
            digest, relative = line.split(maxsplit=1)
            declared[relative] = digest

        expected_paths = {
            str(path.relative_to(PACKAGE))
            for path in MESHES.iterdir()
            if path.is_file()
        }
        expected_paths.add(str(URDF.relative_to(PACKAGE)))
        self.assertEqual(set(declared), expected_paths)

        for relative, expected in declared.items():
            actual = hashlib.sha256((PACKAGE / relative).read_bytes()).hexdigest()
            self.assertEqual(actual, expected, msg=relative)


if __name__ == "__main__":
    unittest.main()
