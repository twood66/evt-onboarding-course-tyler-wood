# Lesson 1: workstation setup and access

Lesson 1 prepares a computer for KSU EVT Python and firmware work. Follow the
complete instructions in the repository root [README](../../README.md).

The setup checker verifies local tools and writes
`progress/setup-report.json`. GitHub Actions validates that report after the
student commits and pushes it.

The `smoke` project targets a Teensy 4.1 and only compiles. No upload target,
serial connection, or hardware command is part of this lesson.

Completion requires:

- Every required local check prints `[PASS]`.
- The checker prints `Lesson 1 complete`.
- The setup report is committed to the student's personal course repository.
- The GitHub `quality` workflow passes.
