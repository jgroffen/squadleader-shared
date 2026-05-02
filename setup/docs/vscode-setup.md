# VSCode Setup

## Installation

To install vscode, browse to:

- https://go.microsoft.com/fwlink/?LinkID=760868

... and download the appropriate deb file. Once available locally run the following commands:

```bash
chmod 666 ./<file>.deb
mv ./<file>.deb /tmp/
sudo apt install /tmp/<file>.deb
rm /tmp/<file>.deb
```

... to:

- make sure _apt user can read the file
- move the file to your /tmp folder
- install vscode
- remove the deb file post-install

## Tips and Tricks

I run Copilot CLI in a Terminal-In-Editor tab. One way to do this is to use the command pallette and search for `Terminal in editor`. I have made a new short-cut by using the command pallette to search for `open keyboard shortcuts` (or pressing  `CTRL`+`K` then `CT
RL`+`S`) ... then searching for `Terminal in editor`. I am using:

- `SHIFT`+`ALT`+`T`: Open a terminal in an editor tab

## Useful VSCode Shortcuts

- `CTRL`+`` ` `` or `CTRL`+`J`: Open a terminal
- `CTRL`+`SHIFT`+`P`: Search the VSCode Command Pallette

## Recommended VSCode Extensions

- Better Comments
- Black Formatter (for Python)
- Error Lens
- ESLint
- Git Lens
- Markdown All in One
- NPM Intellisense
- Path Intellisense
- Prettier - Code formatter
- Pylint
- Python Language Support
- Workspace Explorer
- Yaml

TBD: Highlight has been suggested - could colour-code prompt sections and help differentiate prompt structures per agent.