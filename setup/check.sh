#!/usr/bin/env bash

set -uo pipefail

course_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
mode="public"

case "${1:-}" in
  "") ;;
  --member) mode="member" ;;
  --help|-h)
    printf '%s\n' \
      "Usage: ./setup/check.sh [--member]" \
      "" \
      "Run without --member for the public course." \
      "Use --member to require access to the team member repository."
    exit 0
    ;;
  *)
    printf 'Unknown option: %s\n' "$1" >&2
    exit 2
    ;;
esac

case "$(uname -s)" in
  Darwin) platform="macos" ;;
  Linux) platform="linux" ;;
  *)
    printf 'This checker supports macOS and Linux. Use setup/check.ps1 on Windows.\n' >&2
    exit 2
    ;;
esac

show_result() {
  local label=$1
  local result=$2
  if [[ "$result" == "true" ]]; then
    printf '[PASS] %s\n' "$label"
  else
    printf '[FAIL] %s\n' "$label"
  fi
}

git_installed=false
git_identity=false
github_cli=false
github_authenticated=false
public_repo_access=false
vscode=false
extension_pack=false
python_extension=false
platformio_extension=false
github_extension=false
markdown_extension=false
python_runtime=false
pip=false
platformio_cli=false
cpp_build=false
team_access_json='"not_required"'

if command -v git >/dev/null 2>&1; then
  git_installed=true
  if git config --global --get user.name >/dev/null 2>&1 &&
    git config --global --get user.email >/dev/null 2>&1; then
    git_identity=true
  fi
fi
show_result "Git is installed" "$git_installed"
show_result "Git name and email are configured" "$git_identity"

if command -v gh >/dev/null 2>&1; then
  github_cli=true
  if gh auth status --hostname github.com >/dev/null 2>&1; then
    github_authenticated=true
    if gh repo view KSU-Electric-Vehicle-Team/ROB-Teensy >/dev/null 2>&1; then
      public_repo_access=true
    fi
    if [[ "$mode" == "member" ]]; then
      if gh repo view KSU-Electric-Vehicle-Team/evt-knowledge >/dev/null 2>&1; then
        team_access_json=true
      else
        team_access_json=false
      fi
    fi
  elif [[ "$mode" == "member" ]]; then
    team_access_json=false
  fi
fi
show_result "GitHub CLI is installed" "$github_cli"
show_result "GitHub CLI is authenticated" "$github_authenticated"
show_result "Public KSU EVT repository access works" "$public_repo_access"
if [[ "$mode" == "member" ]]; then
  show_result "Team member repository access works" "$team_access_json"
fi

code_cli=""
if command -v code >/dev/null 2>&1; then
  code_cli=$(command -v code)
elif [[ "$platform" == "macos" ]] &&
  [[ -x "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" ]]; then
  code_cli="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
fi

if [[ -n "$code_cli" ]]; then
  vscode=true
  extensions=$("$code_cli" --list-extensions 2>/dev/null | tr '[:upper:]' '[:lower:]')
  if grep -Eq "^ksu-evt\.ksu-evt-(lite|full)-${platform}$" <<<"$extensions"; then
    extension_pack=true
  fi
  if grep -Fqx "ms-python.python" <<<"$extensions"; then
    python_extension=true
  fi
  if grep -Fqx "platformio.platformio-ide" <<<"$extensions"; then
    platformio_extension=true
  fi
  if grep -Fqx "github.vscode-pull-request-github" <<<"$extensions"; then
    github_extension=true
  fi
  if grep -Fqx "davidanson.vscode-markdownlint" <<<"$extensions"; then
    markdown_extension=true
  fi
fi
show_result "VS Code is installed and its command works" "$vscode"
show_result "The matching KSU EVT extension pack is installed" "$extension_pack"
show_result "The Python extension is installed" "$python_extension"
show_result "The PlatformIO extension is installed" "$platformio_extension"
show_result "The GitHub Pull Requests extension is installed" "$github_extension"
show_result "The markdownlint extension is installed" "$markdown_extension"

python_cli=""
if command -v python3 >/dev/null 2>&1; then
  python_cli=$(command -v python3)
elif command -v python >/dev/null 2>&1; then
  python_cli=$(command -v python)
fi

if [[ -n "$python_cli" ]] && "$python_cli" --version >/dev/null 2>&1; then
  python_runtime=true
  if "$python_cli" -m pip --version >/dev/null 2>&1; then
    pip=true
  fi
fi
show_result "Python runs" "$python_runtime"
show_result "pip runs through Python" "$pip"

pio_cli=""
if command -v pio >/dev/null 2>&1; then
  pio_cli=$(command -v pio)
elif [[ -x "$HOME/.platformio/penv/bin/pio" ]]; then
  pio_cli="$HOME/.platformio/penv/bin/pio"
elif [[ -x "$HOME/.platformio/penv/bin/platformio" ]]; then
  pio_cli="$HOME/.platformio/penv/bin/platformio"
fi

if [[ -n "$pio_cli" ]] && "$pio_cli" --version >/dev/null 2>&1; then
  platformio_cli=true
  printf '\nCompiling the no-hardware Teensy smoke project. This may download the toolchain.\n'
  if "$pio_cli" run \
    --project-dir "$course_root/lessons/01-setup/smoke" \
    --environment teensy41; then
    cpp_build=true
  fi
fi
show_result "PlatformIO Core runs" "$platformio_cli"
show_result "The Teensy smoke project compiles" "$cpp_build"

complete=true
for result in \
  "$git_installed" \
  "$git_identity" \
  "$github_cli" \
  "$github_authenticated" \
  "$public_repo_access" \
  "$vscode" \
  "$extension_pack" \
  "$python_extension" \
  "$platformio_extension" \
  "$github_extension" \
  "$markdown_extension" \
  "$python_runtime" \
  "$pip" \
  "$platformio_cli" \
  "$cpp_build"; do
  if [[ "$result" != "true" ]]; then
    complete=false
  fi
done
if [[ "$mode" == "member" ]] && [[ "$team_access_json" != "true" ]]; then
  complete=false
fi

mkdir -p "$course_root/progress"
report_path="$course_root/progress/setup-report.json"
generated_at=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
cat >"$report_path" <<JSON
{
  "schema_version": 1,
  "generated_at": "$generated_at",
  "platform": "$platform",
  "mode": "$mode",
  "checks": {
    "git_installed": $git_installed,
    "git_identity": $git_identity,
    "github_cli": $github_cli,
    "github_authenticated": $github_authenticated,
    "public_repo_access": $public_repo_access,
    "team_access": $team_access_json,
    "vscode": $vscode,
    "extension_pack": $extension_pack,
    "python_extension": $python_extension,
    "platformio_extension": $platformio_extension,
    "github_extension": $github_extension,
    "markdown_extension": $markdown_extension,
    "python_runtime": $python_runtime,
    "pip": $pip,
    "platformio_cli": $platformio_cli,
    "cpp_build": $cpp_build
  },
  "complete": $complete
}
JSON

printf '\nSetup report: %s\n' "$report_path"
if [[ "$complete" == "true" ]]; then
  printf 'Lesson 1 complete. Commit the report and push it to GitHub.\n'
  exit 0
fi

printf 'Setup is incomplete. Follow the troubleshooting section in README.md, then run this checker again.\n'
exit 1
