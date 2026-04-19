# VSCode Setup

## Quick Start





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