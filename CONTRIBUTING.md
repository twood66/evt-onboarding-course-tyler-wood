# Contributing

Use an issue or a small pull request for course changes. Keep the beginner path
short and test every changed command.

Before requesting review:

```sh
python3 -m unittest discover -s tests -v
bash -n setup/check.sh
python3 scripts/validate_setup_report.py
pio run --project-dir lessons/01-setup/smoke --environment teensy41
```

Windows checker changes also need a real PowerShell run on Windows. macOS setup
changes need a real macOS run.

Do not commit generated PlatformIO build directories, credentials, personal
setup reports, or private team data to the source repository.
