# Milva IO — Mac Dev Setup

Interactive shell script for setting up a new Mac development environment at Milva IO.

## Usage

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/team-milva/Milva-IO-dev-setup/master/mac_setup.sh)
```

An interactive menu will appear listing everything that will be installed. Press **Enter** to start or **Ctrl+C** to abort.

## What gets installed

| Component | Description |
|---|---|
| Xcode CLT | Xcode Command Line Tools |
| Homebrew | Package manager |
| gh | GitHub CLI |
| nvm | Node Version Manager |
| pyenv + Python | Python version manager + latest Python |
| OpenJDK | Java runtime |
| Visual Studio Code | Code editor |
| Google Chrome | Browser |
| GitHub Desktop | Git GUI client |
| Insomnia | API client |
| Slack | Team communication |
| Obsidian | Note-taking |
| Claude | Claude desktop app |
| Google Cloud SDK | gcloud CLI |
| Node.js | Latest Node via nvm |
| firebase-tools | Firebase CLI (npm global) |
| .zshrc config | nvm + pyenv shell setup |
| gh auth login | GitHub CLI authentication |
| Uniqkey | Chrome extension (password manager) |

## Controls

- **Enter** — start installation
- **Ctrl+C** — abort

## After setup

- Restart the terminal or run `source ~/.zshrc`
- Sign in to apps: Slack, Obsidian, Claude
