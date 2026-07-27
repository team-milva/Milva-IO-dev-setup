#!/bin/bash
# =============================================================================
# Mac Work Environment Setup — jonatan@milva.io
# =============================================================================

# --- Farver ---
GREEN='\033[0;32m'; GRAY='\033[0;90m'; BOLD='\033[1m'; RESET='\033[0m'

# --- Keys, labels en selectie (parallelle arrays — werkt op bash 3) ---
# Indices: 0=xcode 1=homebrew 2=gh 3=nvm 4=pyenv 5=openjdk 6=vscode 7=chrome
#          8=github_desktop 9=insomnia 10=slack 11=obsidian 12=claude 13=gcloud
#          14=node 15=firebase 16=zshrc 17=gh_login
KEYS=(xcode homebrew gh nvm pyenv openjdk vscode chrome github_desktop insomnia slack obsidian claude gcloud node firebase zshrc gh_login)

LABELS=(
  "xcode           Xcode Command Line Tools"
  "homebrew        Homebrew"
  "gh              gh — GitHub CLI"
  "nvm             nvm — Node Version Manager"
  "pyenv           pyenv + Python (latest)"
  "openjdk         OpenJDK — Java runtime"
  "vscode          Visual Studio Code"
  "chrome          Google Chrome"
  "github_desktop  GitHub Desktop"
  "insomnia        Insomnia (API-klient)"
  "slack           Slack"
  "obsidian        Obsidian"
  "claude          Claude desktop app"
  "gcloud          Google Cloud SDK"
  "node            Node.js (latest via nvm)"
  "firebase        firebase-tools (npm global)"
  "zshrc           .zshrc opsætning (nvm + pyenv)"
  "gh_login        gh auth login"
)

# Parallel selectie-array (1=aan, 0=uit) — geen associatieve array nodig
SEL=(1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1)

# Helper: geeft index terug van een key
key_idx() {
  local k=$1 i
  for i in "${!KEYS[@]}"; do
    [[ "${KEYS[$i]}" == "$k" ]] && echo $i && return
  done
}

# Shorthand: is key geselecteerd?
is_sel() { [[ "${SEL[$(key_idx "$1")]}" == "1" ]]; }

# --- Farver ekstra ---
WHITE='\033[1;37m'; BG_BLUE='\033[44m'

draw_menu() {
  local cursor=$1
  clear
  echo ""
  echo -e "  ${BOLD}${WHITE}Mac Setup — vælg hvad der skal installeres${RESET}"
  echo -e "  ${GRAY}↑↓ naviger   Space toggle   a alle   n ingen   Enter start${RESET}"
  echo ""
  local i
  for i in "${!KEYS[@]}"; do
    local label="${LABELS[$i]}"
    local checked="${SEL[$i]}"
    if [[ $i -eq $cursor ]]; then
      if [[ "$checked" == "1" ]]; then
        echo -e "  ${BG_BLUE}${WHITE}${BOLD} ● ${label} ${RESET}"
      else
        echo -e "  ${BG_BLUE}${WHITE}${BOLD} ○ ${label} ${RESET}"
      fi
    else
      if [[ "$checked" == "1" ]]; then
        echo -e "  ${GREEN} ● ${RESET}${label}"
      else
        echo -e "  ${GRAY} ○ ${label}${RESET}"
      fi
    fi
  done
  echo ""
  local count=0 i
  for i in "${!SEL[@]}"; do [[ "${SEL[$i]}" == "1" ]] && ((count++)); done
  echo -e "  ${GRAY}${count}/${#KEYS[@]} valgt${RESET}"
  echo ""
}

# --- Interaktiv menu med piltaster ---
cursor=0
total=${#KEYS[@]}

while true; do
  draw_menu $cursor

  IFS= read -rsn1 key
  if [[ $key == $'\x1b' ]]; then
    read -rsn2 -t 0.1 seq
    case "$seq" in
      '[A') (( cursor = (cursor - 1 + total) % total )) ;;  # Op
      '[B') (( cursor = (cursor + 1) % total ))          ;;  # Ned
    esac
  elif [[ $key == ' ' ]]; then
    SEL[$cursor]=$(( 1 - SEL[$cursor] ))
  elif [[ $key == 'a' ]]; then
    for i in "${!SEL[@]}"; do SEL[$i]=1; done
  elif [[ $key == 'n' ]]; then
    for i in "${!SEL[@]}"; do SEL[$i]=0; done
  elif [[ $key == '' ]]; then
    break
  fi
done

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
