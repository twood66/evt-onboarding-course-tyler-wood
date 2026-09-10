#!/usr/bin/env python3

from __future__ import annotations

import json
import os
import sys
from pathlib import Path
from typing import Any

REPORT_PATH = Path("progress/setup-report.json")
PLATFORMS = {"windows", "macos", "linux"}
MODES = {"public", "member"}
REQUIRED_BOOLEAN_CHECKS = {
    "git_installed",
    "git_identity",
    "github_cli",
    "github_authenticated",
    "public_repo_access",
    "vscode",
    "extension_pack",
    "python_extension",
    "platformio_extension",
    "github_extension",
    "markdown_extension",
    "python_runtime",
    "pip",
    "platformio_cli",
    "cpp_build",
}


def load_report(path: Path) -> dict[str, Any]:
    with path.open(encoding="utf-8-sig") as report_file:
        report = json.load(report_file)
    if not isinstance(report, dict):
        raise ValueError("the report root must be a JSON object")
    return report


def validate_report(report: dict[str, Any]) -> list[str]:
    errors: list[str] = []

    if report.get("schema_version") != 1:
        errors.append("schema_version must be 1")

    platform = report.get("platform")
    if platform not in PLATFORMS:
        errors.append("platform must be windows, macos, or linux")

    mode = report.get("mode")
    if mode not in MODES:
        errors.append("mode must be public or member")

    checks = report.get("checks")
    if not isinstance(checks, dict):
        errors.append("checks must be a JSON object")
        return errors

    for check_name in sorted(REQUIRED_BOOLEAN_CHECKS):
        value = checks.get(check_name)
        if not isinstance(value, bool):
            errors.append(f"checks.{check_name} must be true or false")
        elif not value:
            errors.append(f"checks.{check_name} did not pass")

    team_access = checks.get("team_access")
    if mode == "public":
        if team_access != "not_required":
            errors.append('checks.team_access must be "not_required" in public mode')
    elif mode == "member" and team_access is not True:
        errors.append("checks.team_access must pass in member mode")

    if report.get("complete") is not True:
        errors.append("complete must be true")

    return errors


def write_summary(report: dict[str, Any] | None, errors: list[str]) -> None:
    summary_path = os.environ.get("GITHUB_STEP_SUMMARY")
    if not summary_path:
        return

    lines = ["## KSU EVT setup report", ""]
    if report is None:
        lines.extend(
            [
                "No setup report has been submitted yet.",
                "",
                "Run the checker in `setup/`, then commit `progress/setup-report.json`.",
            ]
        )
    elif errors:
        lines.append("The setup report is incomplete:")
        lines.append("")
        lines.extend(f"- {error}" for error in errors)
    else:
        lines.extend(
            [
                f"Lesson 1 passed in **{report['mode']}** mode on **{report['platform']}**.",
                "",
                "The local checker confirmed the required tools, extensions, access, and no-hardware firmware build.",
            ]
        )

    with open(summary_path, "a", encoding="utf-8") as summary_file:
        summary_file.write("\n".join(lines) + "\n")


def main() -> int:
    path = Path(sys.argv[1]) if len(sys.argv) > 1 else REPORT_PATH
    if not path.exists():
        print(
            "::notice::No setup report yet. Run the Lesson 1 checker and commit progress/setup-report.json."
        )
        write_summary(None, [])
        return 0

    try:
        report = load_report(path)
    except (OSError, json.JSONDecodeError, ValueError) as error:
        print(f"::error file={path}::{error}")
        write_summary({}, [str(error)])
        return 1

    errors = validate_report(report)
    write_summary(report, errors)
    if errors:
        for error in errors:
            print(f"::error file={path}::{error}")
        return 1

    print("Lesson 1 setup report is complete.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
