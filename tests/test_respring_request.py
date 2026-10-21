"""Exercise the package-manager completion pipe without restarting anything."""

import os
from pathlib import Path
import subprocess
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / "layout/DEBIAN/postinst"


class RespringRequestTests(unittest.TestCase):
    def invoke(self, channels, action="configure"):
        read_fd, write_fd = os.pipe()
        environment = os.environ.copy()
        environment.pop("SILEO", None)
        environment.pop("CYDIA", None)
        environment.update({key: value.format(fd=write_fd) for key, value in channels.items()})
        try:
            result = subprocess.run(
                [str(SCRIPT), action], env=environment, pass_fds=(write_fd,),
                capture_output=True, timeout=5, check=False,
            )
        finally:
            os.close(write_fd)
        try:
            signal = os.read(read_fd, 4096)
        finally:
            os.close(read_fd)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, b"")
        self.assertEqual(result.stderr, b"")
        return signal

    def test_sileo_receives_respring_request(self):
        self.assertEqual(self.invoke({"SILEO": "{fd} 1"}), b"finish:restart\n")

    def test_cydia_compatibility_channel(self):
        self.assertEqual(self.invoke({"CYDIA": "{fd} 1"}), b"finish:restart\n")

    def test_both_channels_emit_only_once(self):
        self.assertEqual(self.invoke({"SILEO": "{fd} 1", "CYDIA": "{fd} 1"}),
                         b"finish:restart\n")

    def test_closed_sileo_channel_falls_back_to_cydia(self):
        self.assertEqual(self.invoke({"SILEO": "9999 1", "CYDIA": "{fd} 1"}),
                         b"finish:restart\n")

    def test_cli_install_without_manager_still_succeeds(self):
        self.assertEqual(self.invoke({}), b"")

    def test_invalid_channel_does_not_fail_installation(self):
        self.assertEqual(self.invoke({"SILEO": "invalid 1"}), b"")

    def test_closed_channel_does_not_fail_installation(self):
        self.assertEqual(self.invoke({"SILEO": "9999 1"}), b"")

    def test_failure_recovery_actions_do_not_request_respring(self):
        for action in ["abort-upgrade", "abort-remove", "abort-deconfigure"]:
            with self.subTest(action=action):
                self.assertEqual(self.invoke({"SILEO": "{fd} 1"}, action), b"")


if __name__ == "__main__":
    unittest.main()
