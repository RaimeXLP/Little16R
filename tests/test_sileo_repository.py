"""Checks for Sileo's flat-repository metadata and download requirements."""

from email.parser import Parser
import hashlib
import io
from pathlib import Path
import runpy
import tarfile
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
BUILD_REPOSITORY = runpy.run_path(str(ROOT / "scripts/build_repo.py"))["build_repository"]


def control_archive(control):
    stream = io.BytesIO()
    with tarfile.open(fileobj=stream, mode="w:gz") as archive:
        entry = tarfile.TarInfo("./control")
        entry.size = len(control)
        archive.addfile(entry, io.BytesIO(control))
    return stream.getvalue()


class SileoRepositoryTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="little16r-sileo-test-")
        self.addCleanup(self.temporary.cleanup)
        root = Path(self.temporary.name)
        packages = root / "packages"
        packages.mkdir()
        self.output = root / "site"
        name = "io.github.raimexlp.little16r_0.1.0~alpha1_iphoneos-arm.deb"
        control = (
            b"Package: io.github.raimexlp.little16r\n"
            b"Version: 0.1.0~alpha1\nArchitecture: iphoneos-arm\n"
            b"Name: Little16R\nDescription: Test fixture\n"
            b"Author: Leon Prinz\n"
        )
        archive = bytearray(b"!<arch>\n")
        for member, data in [("debian-binary", b"2.0\n"),
                             ("control.tar.gz", control_archive(control))]:
            header = f"{member + '/':<16}{0:<12}{0:<6}{0:<6}{100644:<8}{len(data):<10}`\n"
            archive.extend(header.encode() + data + (b"\n" if len(data) % 2 else b""))
        (packages / name).write_bytes(archive)
        BUILD_REPOSITORY(packages, self.output, ROOT / "repo", "test", "test")
        self.release = Parser().parsestr((self.output / "Release").read_text())

    def test_sileo_required_release_fields(self):
        # RepoManager requires Components even when repo.isFlat is true.
        # This is separate from its earlier check for a supported architecture.
        self.assertIn("iphoneos-arm", self.release["Architectures"].split())
        self.assertIn("Components", self.release)
        self.assertIn("main", self.release["Components"].split())

    def test_release_hashes_match_available_indices(self):
        for field, algorithm in [("MD5Sum", "md5"), ("SHA1", "sha1"),
                                 ("SHA256", "sha256"), ("SHA512", "sha512")]:
            self.assertTrue(self.release[field])
            for line in self.release[field].strip().splitlines():
                digest, size, filename = line.split()
                payload = (self.output / filename).read_bytes()
                self.assertEqual(len(payload), int(size))
                self.assertEqual(hashlib.new(algorithm, payload).hexdigest(), digest)

    def test_flat_package_path_and_download_hash(self):
        package = Parser().parsestr((self.output / "Packages").read_text())
        self.assertEqual(package["Package"], "io.github.raimexlp.little16r")
        self.assertTrue(package["Filename"].startswith("pool/"))
        self.assertNotIn("..", Path(package["Filename"]).parts)
        payload = (self.output / package["Filename"]).read_bytes()
        self.assertEqual(int(package["Size"]), len(payload))
        self.assertEqual(package["SHA256"], hashlib.sha256(payload).hexdigest())
        self.assertFalse((self.output / "dists").exists())


if __name__ == "__main__":
    unittest.main()
