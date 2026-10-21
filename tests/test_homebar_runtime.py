"""Native hook/ABI tests on macOS; the iOS package is compiled separately."""
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


@unittest.skipUnless(sys.platform == "darwin", "Objective-C host tests require macOS")
class HomebarRuntimeTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.temp = tempfile.TemporaryDirectory(prefix="little16r-runtime-")
        cls.addClassCleanup(cls.temp.cleanup)
        cls.binary = Path(cls.temp.name) / "homebar-runtime"
        subprocess.run([
            "xcrun", "clang", "-fobjc-arc", "-fblocks", "-Wall", "-Wextra",
            "-Wno-unused-function", "-framework", "Foundation", "-framework", "CoreGraphics",
            "-I", str(ROOT / "tests/objc_stubs"),
            str(ROOT / "tests/homebar_runtime.m"), "-o", str(cls.binary),
        ], check=True, capture_output=True, text=True)

    def check_mode(self, mode):
        result = subprocess.run([str(self.binary), mode], capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_off_disables_indicator_without_changing_layout(self):
        self.check_mode("off")

    def test_on_keeps_indicator_and_preserves_safe_area_edges(self):
        self.check_mode("on")

    def test_incompatible_orientation_skips_entire_inset_group(self):
        self.check_mode("bad-abi")
