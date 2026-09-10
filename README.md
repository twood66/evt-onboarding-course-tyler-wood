# KSU EVT developer onboarding

This is the self-paced setup and practice course for the KSU Electric Vehicle
Team. Lesson 1 checks a student's computer without flashing hardware or reading
private repository contents.

The course supports Windows, macOS, and Linux. Students can complete the public
track without joining the KSU EVT GitHub organization. Current team members can
run the member check to confirm their private repository access.

## What Lesson 1 proves

A completed setup report confirms that:

- Git is installed and has a name and email configured.
- GitHub CLI is installed and signed into GitHub.
- The computer can read the public KSU EVT firmware repository.
- VS Code and the correct operating-system extension pack are installed.
- The Python, PlatformIO, GitHub Pull Requests, and markdownlint extensions are
  available.
- Python and pip run from the terminal.
- PlatformIO Core runs from the terminal.
- The Teensy 4.1 toolchain can compile a small firmware project.
- Team members can read the approved private access-check repository.

The firmware check only compiles. It does not upload code, connect to a board,
open a serial port, or change vehicle behavior.

## What the automation cannot do

The checker does not create accounts, accept organization invitations, sign
into GitHub, approve extension trust prompts, bypass administrator controls, or
install system software without the student's knowledge. Those steps require a
person because they affect an account or computer outside this repository.

The checker tells the student exactly which requirement is missing, writes a
small report containing booleans rather than personal data, and exits with a
failure until the setup works.

## Lesson 1 quick start

Complete these steps in order:

1. Install Git, GitHub CLI, VS Code, and Python.
2. Configure your Git name and email.
3. Sign into GitHub through GitHub CLI.
4. Install one KSU EVT VS Code extension pack.
5. Create your personal copy of this course.
6. Clone your personal copy.
7. Run the setup checker.
8. Fix every failed check and run it again.
9. Commit `progress/setup-report.json` and push it.
10. Open the Actions page in your repository and confirm that `quality` is
    green.

The detailed instructions below cover every step.

## 1. Install the system tools

You need:

- [Git](https://git-scm.com/downloads)
- [GitHub CLI](https://cli.github.com/)
- [Visual Studio Code](https://code.visualstudio.com/download)
- [Python](https://www.python.org/downloads/), version 3.11 or newer

### Windows

Open PowerShell as your normal user. If `winget` is available, run:

```powershell
winget install --id Git.Git -e
winget install --id GitHub.cli -e
winget install --id Microsoft.VisualStudioCode -e
winget install --id Python.Python.3.13 -e
```

Close and reopen PowerShell after installation. Confirm the commands work:

```powershell
git --version
gh --version
code --version
python --version
python -m pip --version
```

If Windows opens the Microsoft Store when you enter `python`, disable the
`python.exe` App execution alias in Windows Settings or reinstall Python with
the `Add Python to PATH` option enabled.

### macOS

Install from the official download links above, or use Homebrew:

```sh
brew install git gh python
brew install --cask visual-studio-code
```

VS Code's `code` command may not initially be on `PATH`. The checker can find a
normal `/Applications` installation, but adding the command makes later lessons
easier:

1. Open VS Code.
2. Press `Cmd+Shift+P`.
3. Run `Shell Command: Install 'code' command in PATH`.
4. Close and reopen the terminal.

Confirm the tools:

```sh
git --version
gh --version
code --version
python3 --version
python3 -m pip --version
```

### Linux

Install VS Code from the official download page. Install the other tools with
your distribution's package manager.

Debian or Ubuntu:

```sh
sudo apt update
sudo apt install git gh python3 python3-pip
```

Fedora:

```sh
sudo dnf install git gh python3 python3-pip
```

Arch Linux or CachyOS:

```sh
sudo pacman -S git github-cli python python-pip
```

Confirm the tools:

```sh
git --version
gh --version
code --version
python3 --version
python3 -m pip --version
```

If your distribution does not package `gh`, follow the installation link on
the GitHub CLI website instead of downloading a random binary.

## 2. Configure Git

Use your real name and the email attached to your GitHub account:

```sh
git config --global user.name "YOUR NAME"
git config --global user.email "YOUR EMAIL"
```

You may use a GitHub-provided private commit email. Find it under GitHub
Settings, Emails. The checker only confirms that both fields exist. It never
writes their values into the setup report.

Confirm the configuration locally:

```sh
git config --global --get user.name
git config --global --get user.email
```

## 3. Sign into GitHub CLI

Run:

```sh
gh auth login --hostname github.com --git-protocol https --web
```

Choose GitHub.com and complete the browser sign-in. Do not paste a personal
access token into this repository, an issue, a screenshot, or the setup report.

Confirm the session:

```sh
gh auth status --hostname github.com
```

Public-course students only need a personal GitHub account. Team members must
also accept the organization invitation sent by a KSU EVT owner before the
member access check can pass.

## 4. Install the KSU EVT extension pack

Lite is enough for Lesson 1. Full adds Jupyter, Django, Python utilities,
firmware debugging, telemetry, and documentation tools.

| Operating system | Lite | Full |
| --- | --- | --- |
| Windows | [Download Lite for Windows](https://github.com/KSU-Electric-Vehicle-Team/vscode-extension-packs/releases/download/v0.2.0/ksu-evt-lite-windows-0.2.0.vsix) | [Download Full for Windows](https://github.com/KSU-Electric-Vehicle-Team/vscode-extension-packs/releases/download/v0.2.0/ksu-evt-full-windows-0.2.0.vsix) |
| macOS | [Download Lite for macOS](https://github.com/KSU-Electric-Vehicle-Team/vscode-extension-packs/releases/download/v0.2.0/ksu-evt-lite-macos-0.2.0.vsix) | [Download Full for macOS](https://github.com/KSU-Electric-Vehicle-Team/vscode-extension-packs/releases/download/v0.2.0/ksu-evt-full-macos-0.2.0.vsix) |
| Linux | [Download Lite for Linux](https://github.com/KSU-Electric-Vehicle-Team/vscode-extension-packs/releases/download/v0.2.0/ksu-evt-lite-linux-0.2.0.vsix) | [Download Full for Linux](https://github.com/KSU-Electric-Vehicle-Team/vscode-extension-packs/releases/download/v0.2.0/ksu-evt-full-linux-0.2.0.vsix) |

Install the downloaded VSIX inside VS Code:

1. Open the Extensions view with `Ctrl+Shift+X` or `Cmd+Shift+X`.
2. Select the `...` menu at the top of the Extensions view.
3. Select `Install from VSIX...`.
4. Choose the downloaded file.
5. Wait for PlatformIO and its C++ dependency to finish installing.
6. Restart VS Code if it asks.

You can also install from a terminal. Replace the filename with your chosen
download:

```sh
code --install-extension ./ksu-evt-lite-linux-0.2.0.vsix
```

PlatformIO may finish creating its private Python environment the first time
you open VS Code. Wait for its status notification to finish before running the
course checker.

## 5. Create your course copy

Open the [course template page](https://github.com/KSU-Electric-Vehicle-Team/evt-onboarding-course/generate).

1. Select your personal GitHub account as the owner.
2. Keep the repository name `evt-onboarding-course`, or add your username.
3. Choose Public visibility so the course does not consume private-repository
   Actions minutes.
4. Select `Create repository from template`.
5. Wait for GitHub to create the repository.

Do not create the course repository inside the KSU EVT organization. Your
personal account should own your course progress.

## 6. Clone your course copy

Replace `YOUR-USERNAME` with your GitHub username:

```sh
gh repo clone YOUR-USERNAME/evt-onboarding-course
cd evt-onboarding-course
```

If you changed the repository name, use that name in both commands.

Check the remote before continuing:

```sh
git remote -v
```

`origin` should point to your personal account, not directly to the KSU EVT
organization.

## 7. Run the setup checker

### Run on Windows

Open PowerShell in the course folder:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup\check.ps1
```

Current team members can require the private access check:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup\check.ps1 -Member
```

`-ExecutionPolicy Bypass` applies only to this PowerShell process. It does not
change the machine's permanent execution policy.

### Run on macOS or Linux

Run:

```sh
./setup/check.sh
```

Current team members can require the private access check:

```sh
./setup/check.sh --member
```

If the shell reports `Permission denied`, restore the executable bit:

```sh
chmod +x setup/check.sh
./setup/check.sh
```

The first PlatformIO compile can take several minutes because it downloads the
Teensy compiler and Arduino framework. It does not need a connected board.

## 8. Read the results

Every requirement prints either `[PASS]` or `[FAIL]`. The checker always writes
`progress/setup-report.json`, even when the setup is incomplete.

Public mode records private team access as `not_required`. Member mode requires
that access to pass. The report contains:

- Operating-system name
- Public or member mode
- Generation time
- Boolean results for each setup requirement
- One final completion boolean

The report does not contain your name, email, GitHub username, access token,
computer name, home directory, repository contents, or command output.

Open the report before committing it if you want to verify this yourself.

## 9. Fix failed checks

Run the checker again after each fix. Common failures are listed below.

| Failure | Meaning | Fix |
| --- | --- | --- |
| Git is not installed | The `git` command is missing | Install Git, reopen the terminal, and rerun the check |
| Git identity is missing | Git has no global name or email | Run the two `git config --global` commands above |
| GitHub CLI is not authenticated | `gh` has no usable GitHub.com session | Run `gh auth login --hostname github.com --git-protocol https --web` |
| Public repository access failed | GitHub is unavailable or authentication is broken | Open the ROB-Teensy repository in a browser, then rerun `gh auth status` |
| Team access failed | The signed-in account cannot read the member check repository | Accept the organization invitation or ask an owner to verify team access |
| VS Code command failed | VS Code is absent or `code` is not on `PATH` | Reopen the terminal; on macOS install the shell command from VS Code |
| Extension pack failed | The wrong operating-system pack or no pack is installed | Download and install the correct `v0.2.0` VSIX above |
| An extension failed | The pack is still installing or an extension was disabled | Restart VS Code, open Extensions, and confirm the listed extension is enabled |
| Python failed | No usable Python command exists | Install Python 3.11 or newer and reopen the terminal |
| pip failed | Python exists without pip | Repair the Python installation or install your distribution's pip package |
| PlatformIO Core failed | PlatformIO has not finished initializing | Open VS Code, wait for PlatformIO setup, restart the terminal, and rerun |
| Teensy compile failed | The compiler download or build failed | Check internet access, read the PlatformIO error, and rerun the exact command below |

To rerun only the firmware smoke build:

```sh
pio run --project-dir lessons/01-setup/smoke --environment teensy41
```

On Windows, if `pio` is not on `PATH`, use:

```powershell
& "$env:USERPROFILE\.platformio\penv\Scripts\pio.exe" run `
  --project-dir lessons\01-setup\smoke `
  --environment teensy41
```

If you ask for help, include the failed check and the exact error. Remove tokens,
email addresses, and private information from screenshots. Use the repository's
Course help issue form when a public issue is appropriate.

## 10. Submit Lesson 1

Only submit after the checker prints `Lesson 1 complete`.

Review the pending change:

```sh
git status
git diff -- progress/setup-report.json
```

Commit and push:

```sh
git add progress/setup-report.json
git commit -m "Complete workstation setup check"
git push
```

Open the Actions tab in your course repository. Select the newest `quality`
run. A passing run shows `Lesson 1 setup report is complete` in the validator
step and compiles the same no-hardware Teensy project on GitHub's runner.

If Actions are disabled in your personal repository, open Settings, Actions,
General, allow actions, then rerun the workflow from the Actions tab.

## Instructor check for a live class

The instructor does not need to inspect every computer. Ask students to show:

1. A local terminal ending with `Lesson 1 complete`.
2. Their personal course repository.
3. A green `quality` workflow for the commit containing the setup report.

The local result proves the student's machine works. The GitHub result proves
they can clone, commit, push, and use Actions. A green cloud build alone does not
prove their local toolchain works.

## Course roadmap

Lesson 1 is complete and automated now. The remaining lesson directories define
the next course stages:

1. Workstation setup and access
2. GitHub fork, branch, commit, pull request, checks, and review
3. Python telemetry parsing and tests
4. C++ and PlatformIO firmware changes
5. Python and C++ integration

Lesson 2 uses the existing public `github-practice` repository so students can
practice a real fork and pull request without joining the organization. Later
lessons will add their own local tests and Actions checks without changing the
Lesson 1 report format.

## Repository map

```text
.github/
  ISSUE_TEMPLATE/       Public help form
  workflows/            Report validation and no-hardware CI build
docs/                    Instructor and privacy notes
lessons/
  01-setup/              Working setup lesson and Teensy smoke project
  02-github/             GitHub practice path
  03-python/             Python lesson plan
  04-cpp/                C++ lesson plan
  05-integration/        Cross-language lesson plan
progress/                Student-generated course reports
scripts/                 Report validation used by GitHub Actions
setup/                   Windows, macOS, and Linux checkers
tests/                   Validator tests
```

## Safety and privacy

- Never commit GitHub tokens, passwords, private keys, `.env` files, or vehicle
  data.
- Never post private repository contents in a public course issue.
- The setup build never uploads firmware.
- Hardware work requires the supervision and procedure named in the team issue.
- The course does not invite users to the organization or change permissions.
- The workflow has read-only repository permissions.

Read [SECURITY.md](SECURITY.md) before reporting anything that may contain a
credential or private team information.

## Maintaining the course

Course maintainers should read [docs/instructors.md](docs/instructors.md) before
changing a checker, report field, access requirement, or lesson workflow. Pull
requests must keep the source repository's `quality` check green and receive one
code-owner approval.
