from __future__ import annotations

import unittest

from scripts.validate_setup_report import validate_report


def valid_report(mode: str = "public") -> dict[str, object]:
    checks = {
        "git_installed": True,
        "git_identity": True,
        "github_cli": True,
        "github_authenticated": True,
        "public_repo_access": True,
        "team_access": "not_required" if mode == "public" else True,
        "vscode": True,
        "extension_pack": True,
        "python_extension": True,
        "platformio_extension": True,
        "github_extension": True,
        "markdown_extension": True,
        "python_runtime": True,
        "pip": True,
        "platformio_cli": True,
        "cpp_build": True,
    }
    return {
        "schema_version": 1,
        "generated_at": "2026-09-09T12:00:00Z",
        "platform": "linux",
        "mode": mode,
        "checks": checks,
        "complete": True,
    }


class ValidateSetupReportTests(unittest.TestCase):
    def test_public_report_passes(self) -> None:
        self.assertEqual(validate_report(valid_report()), [])

    def test_member_report_passes(self) -> None:
        self.assertEqual(validate_report(valid_report("member")), [])

    def test_failed_tool_is_reported(self) -> None:
        report = valid_report()
        report["checks"]["python_runtime"] = False  # type: ignore[index]
        self.assertIn(
            "checks.python_runtime did not pass",
            validate_report(report),
        )

    def test_member_access_is_required_in_member_mode(self) -> None:
        report = valid_report("member")
        report["checks"]["team_access"] = False  # type: ignore[index]
        self.assertIn(
            "checks.team_access must pass in member mode",
            validate_report(report),
        )

    def test_public_mode_does_not_accept_member_boolean(self) -> None:
        report = valid_report()
        report["checks"]["team_access"] = True  # type: ignore[index]
        self.assertIn(
            'checks.team_access must be "not_required" in public mode',
            validate_report(report),
        )


if __name__ == "__main__":
    unittest.main()
