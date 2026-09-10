# Instructor and maintainer guide

## Current scope

Lesson 1 is the production course. Lessons 2 through 5 are documented course
stages but do not yet have progress-report automation in this repository.
Lesson 2 already uses the separate `github-practice` repository and its quality
check.

Do not tell students that later lessons are automatically graded until their
tests and workflows have been implemented and verified.

## Before a live class

1. Open each of the six `v0.2.0` extension-pack download links from README.
2. Run the public checker once on each operating system available to the
   instructors.
3. Run the member checker with an account that should have private access.
4. Confirm the source repository's latest `quality` run is green.
5. Create a fresh personal repository from the template.
6. Confirm Actions run in that new repository.
7. Confirm the setup report contains no personal values.
8. Keep the public Course help issue form open during class.

The source CI tests Linux execution, Windows PowerShell syntax, report
validation, and a Teensy compile. It does not replace one real Windows and one
real macOS smoke test before a large event.

## Report contract

`progress/setup-report.json` has schema version 1. The checker writes:

- `generated_at`
- `platform`
- `mode`
- `checks`
- `complete`

Every required check except `team_access` is a JSON boolean. Public mode stores
`team_access` as `not_required`. Member mode stores a boolean and requires it to
be true.

When adding a required check:

1. Add it to both setup checkers.
2. Add it to `REQUIRED_BOOLEAN_CHECKS` in the Python validator.
3. Add passing and failing unit tests.
4. Explain the check and its repair path in README.
5. Run the checker on all affected operating systems.
6. Increment `schema_version` if an old report can no longer validate.

## Access checks

Public mode checks only the public ROB-Teensy repository. Member mode checks
read access to `evt-knowledge`. The commands discard output, so the report never
contains repository metadata or content.

Do not change the member access target to a repository containing sensitive
participant, credential, legal, or protected-workspace data. Do not make the
workflow authenticate to private organization repositories.

The checker must never invite a user, accept an invitation, change a team, or
request a token. An owner handles missing access outside the course.

## Hardware boundary

The smoke project runs only `pio run`. Do not add `pio run --target upload`, a
serial monitor, device discovery, USB access, or hardware-control commands to
the course workflow.

A firmware build proves compilation. It does not prove that code is safe for a
controller or vehicle.

## Workflow permissions

The `quality` workflow needs only `contents: read`. Keep it that way while it
validates committed reports and runs builds.

If a future issue-guided lesson needs `issues: write`, put that automation in a
separate workflow. Pin reviewed actions to stable release tags and never run
write-capable workflows on untrusted pull-request code.

## Adding a lesson

Each lesson should fit in 30 to 45 minutes and include:

- One concrete learning goal
- Starter files small enough to read during the lesson
- A local command that checks the work
- The same check in GitHub Actions
- Failure messages that name the file or command to fix
- A completion record under `progress/`
- No secrets, private data, hardware writes, or organization membership
  requirement

Keep the course usable in VS Code but do not prevent another editor from running
the documented commands.

## Source repository settings

The source repository should remain public and marked as a template. Recommended
settings:

- Squash merging only
- Delete branches after merge
- Pull requests required for `main`
- One approval from either code owner
- Stale approval dismissal
- Required `quality` check
- Linear history
- No force pushes or branch deletion
- Read-only default Actions permission

Personal copies belong to students. Do not require them to add instructors as
collaborators or transfer repositories into the organization.
