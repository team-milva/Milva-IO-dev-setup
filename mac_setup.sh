#!/bin/bash
# =============================================================================
# Mac Work Environment Setup — jonatan@milva.io
# =============================================================================

# --- Farver ---
GREEN='\033[0;32m'; GRAY='\033[0;90m'; BOLD='\033[1m'; RESET='\033[0m'

# --- Hvad installeres ---
clear
echo ""
echo -e "  ${BOLD}Mac Setup — Milva IO${RESET}"
echo -e "  ${GRAY}Følgende vil blive installeret:${RESET}"
echo ""
echo -e "  ${GREEN}✓${RESET}  Xcode Command Line Tools"
echo -e "  ${GREEN}✓${RESET}  Homebrew"
echo -e "  ${GREEN}✓${RESET}  gh — GitHub CLI"
echo -e "  ${GREEN}✓${RESET}  nvm + Node.js (latest)"
echo -e "  ${GREEN}✓${RESET}  pyenv + Python (latest)"
echo -e "  ${GREEN}✓${RESET}  OpenJDK"
echo -e "  ${GREEN}✓${RESET}  Visual Studio Code"
echo -e "  ${GREEN}✓${RESET}  Google Chrome"
echo -e "  ${GREEN}✓${RESET}  GitHub Desktop"
echo -e "  ${GREEN}✓${RESET}  Insomnia"
echo -e "  ${GREEN}✓${RESET}  Slack"
echo -e "  ${GREEN}✓${RESET}  Obsidian"
echo -e "  ${GREEN}✓${RESET}  Claude"
echo -e "  ${GREEN}✓${RESET}  Google Cloud SDK"
echo -e "  ${GREEN}✓${RESET}  firebase-tools"
echo -e "  ${GREEN}✓${RESET}  .zshrc opsætning"
echo -e "  ${GREEN}✓${RESET}  gh auth login"
echo -e "  ${GREEN}✓${RESET}  Uniqkey (Chrome-udvidelse)"
echo ""
read -rp "  Tryk Enter for at starte, eller Ctrl+C for at afbryde... "
echo ""

# Shorthand: altid sand (alt installeres)
is_sel() { return 0; }

set -e
echo ""
echo "🚀 Starter installation..."

# =============================================================================
# XCODE COMMAND LINE TOOLS
# =============================================================================
if is_sel xcode; then
  echo "\n📦 Xcode Command Line Tools..."
  if ! xcode-select -p &>/dev/null; then
    xcode-select --install
    echo "Vent til Xcode CLT er installeret, tryk derefter Enter for at fortsætte..."
    read -r
  else
    echo "✓ Allerede installeret"
  fi
fi

# =============================================================================
# HOMEBREW
# =============================================================================
if is_sel homebrew; then
  echo "\n🍺 Homebrew..."
  if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    echo "✓ Allerede installeret — opdaterer..."
    brew update
  fi
fi

# =============================================================================
# HOMEBREW FORMULAS
# =============================================================================
FORMULAS=()
is_sel gh      && FORMULAS+=(gh)
is_sel nvm     && FORMULAS+=(nvm)
is_sel pyenv   && FORMULAS+=(pyenv)
is_sel openjdk && FORMULAS+=(openjdk)

if [[ ${#FORMULAS[@]} -gt 0 ]]; then
  echo "\n📦 Homebrew formulas: ${FORMULAS[*]}..."
  brew install "${FORMULAS[@]}"
fi

# Python via pyenv
if is_sel pyenv; then
  LATEST_PYTHON=$(pyenv install --list | grep -E "^\s+[0-9]+\.[0-9]+\.[0-9]+$" | tail -1 | tr -d ' ')
  echo "📦 Installerer Python $LATEST_PYTHON..."
  pyenv install "$LATEST_PYTHON"
  pyenv global "$LATEST_PYTHON"
fi

# =============================================================================
# HOMEBREW CASKS
# =============================================================================
CASKS=()
is_sel vscode          && CASKS+=(visual-studio-code)
is_sel chrome          && CASKS+=(google-chrome)
is_sel github_desktop  && CASKS+=(github)
is_sel insomnia        && CASKS+=(insomnia)
is_sel slack           && CASKS+=(slack)
is_sel obsidian        && CASKS+=(obsidian)
is_sel claude          && CASKS+=(claude)
is_sel gcloud          && CASKS+=(google-cloud-sdk)

if [[ ${#CASKS[@]} -gt 0 ]]; then
  echo "\n🖥️  Apps: ${CASKS[*]}..."
  brew install --cask "${CASKS[@]}"
fi

# =============================================================================
# NODE
# =============================================================================
if is_sel node; then
  echo "\n📗 Node.js (latest) via nvm..."
  export NVM_DIR="$HOME/.nvm"
  mkdir -p "$NVM_DIR"
  [ -s "$(brew --prefix nvm)/nvm.sh" ] && source "$(brew --prefix nvm)/nvm.sh"
  nvm install node
  nvm use node
  nvm alias default node
  echo "✓ Node $(node -v) installeret"
fi

# =============================================================================
# NPM GLOBALS
# =============================================================================
if is_sel firebase; then
  echo "\n📦 firebase-tools..."
  npm install -g firebase-tools
fi

# =============================================================================
# ZSHRC
# =============================================================================
if is_sel zshrc; then
  echo "\n⚙️  ~/.zshrc..."
  ZSHRC="$HOME/.zshrc"

  if ! grep -q 'NVM_DIR' "$ZSHRC" 2>/dev/null; then
cat >> "$ZSHRC" << 'EOF'

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$(brew --prefix nvm)/nvm.sh" ] && \. "$(brew --prefix nvm)/nvm.sh"
[ -s "$(brew --prefix nvm)/etc/bash_completion.d/nvm" ] && \. "$(brew --prefix nvm)/etc/bash_completion.d/nvm"
EOF
    echo "✓ NVM tilføjet"
  fi

  if ! grep -q 'pyenv' "$ZSHRC" 2>/dev/null; then
cat >> "$ZSHRC" << 'EOF'

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
EOF
    echo "✓ pyenv tilføjet"
  fi
fi

# =============================================================================
# UNIQKEY — CHROME EXTENSION
# =============================================================================
echo "\n🔑 Uniqkey Chrome-udvidelse..."
EXT_DIR="$HOME/Library/Application Support/Google/Chrome/External Extensions"
mkdir -p "$EXT_DIR"
cat > "$EXT_DIR/pmpjckeomobflnchldnjiafebplbclan.json" << 'EOF'
{
  "external_update_url": "https://clients2.google.com/service/update2/crx"
}
EOF
echo "✓ Uniqkey installeres næste gang Chrome åbnes"

# =============================================================================
# GH LOGIN
# =============================================================================
if is_sel gh_login; then
  echo "\n🔑 GitHub CLI login..."
  gh auth login
fi

# =============================================================================
# DONE
# =============================================================================
echo "\n✅ Setup færdigt!"
echo ""
echo "Næste trin:"
echo "  • Log ind i apps: Slack, Obsidian, Claude"
echo "  • Genstart terminalen: source ~/.zshrc"
