# Terminal

macOS Terminal.app profile setup.

Run:

```sh
bash terminal/setup.sh
```

This creates or updates a `Personal Tokyo Night` profile with:

- FiraCode Nerd Font Mono, size 20
- Main Tokyo Night colors
- Default and startup profile set to `Personal Tokyo Night`

You can override the profile name, font, or size:

```sh
TERMINAL_FONT_SIZE=18 bash terminal/setup.sh
TERMINAL_FONT=SFMonoTerminal-Regular bash terminal/setup.sh
```

Terminal.app transparency is best set manually:

```text
Terminal > Settings > Profiles > Personal Tokyo Night > Text > Background
```

JetBrains Mono is used by Ghostty, but it was not installed in the macOS font
system Terminal.app reads. This setup uses the installed `FiraCodeNFM-Reg`
instead.
