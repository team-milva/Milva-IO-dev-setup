#!/bin/bash
# =============================================================================
# Mac Work Environment Setup — jonatan@milva.io
# =============================================================================

# --- Farver ---
GREEN='\033[0;32m'; GRAY='\033[0;90m'; BOLD='\033[1m'; RESET='\033[0m'

# --- Valgmuligheder: 1 = valgt, 0 = fravalgt ---
declare -A SELECTED
SELECTED=(
  [xcode]=1
  [homebrew]=1
  [gh]=1
  [nvm]=1
  [pyenv]=1
  [openjdk]=1
  [vscode]=1
  [chrome]=1
  [github_desktop]=1
  [insomnia]=1
  [slack]=1
  [obsidian]=1
  [claude]=1
  [gcloud]=1
  [node]=1
  [firebase]=1
  [zshrc]=1
  [gh_login]=1
)

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

KEYS=(xcode homebrew gh nvm pyenv openjdk vscode chrome github_desktop insomnia slack obsidian claude gcloud node firebase zshrc gh_login)

show_menu() {
  clear
  echo ""
  echo -e "  ${BOLD}Mac Setup — vælg hvad der skal installeres${RESET}"
  echo -e "  ${GRAY}Tast nummeret for at toggle. Enter for at starte.${RESET}"
  echo ""
  for i in "${!KEYS[@]}"; do
    key="${KEYS[$i]}"
    label="${LABELS[$i]}"
    num=$(printf "%2d" $((i + 1)))
    if [[ "${SELECTED[$key]}" == "1" ]]; then
      echo -e "  ${GREEN}[✓]${RESET} ${num}. ${label}"
    else
      echo -e "  ${GRAY}[ ]  ${num}. ${label}${RESET}"
    fi
  done
  echo ""
  echo -e "  ${GRAY}[a] Vælg alle   [n] Fravælg alle   [Enter] Start installation${RESET}"
  echo ""
}

# --- Interaktiv menu ---
while true; do
  show_menu
  read -rp "  Valg: " input

  if [[ -z "$input" ]]; then
    break
  elif [[ "$input" == "a" ]]; then
    for key in "${KEYS[@]}"; do SELECTED[$key]=1; done
  elif [[ "$input" == "n" ]]; then
    for key in "${KEYS[@]}"; do SELECTED[$key]=0; done
  elif [[ "$input" =~ ^[0-9]+$ ]] && (( input >= 1 && input <= ${#KEYS[@]} )); then
    key="${KEYS[$((input - 1))]}"
    SELECTED[$key]=$(( 1 - SELECTED[$key] ))
  fi
done

set -e
echo ""
echo "🚀 Starter installation..."

# =============================================================================
# XCODE COMMAND LINE TOOLS
# =============================================================================
if [[ "${SELECTED[xcode]}" == "1" ]]; then
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
if [[ "${SELECTED[homebrew]}" == "1" ]]; then
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
[[ "${SELECTED[gh]}" == "1" ]]      && FORMULAS+=(gh)
[[ "${SELECTED[nvm]}" == "1" ]]     && FORMULAS+=(nvm)
[[ "${SELECTED[pyenv]}" == "1" ]]   && FORMULAS+=(pyenv)
[[ "${SELECTED[openjdk]}" == "1" ]] && FORMULAS+=(openjdk)

if [[ ${#FORMULAS[@]} -gt 0 ]]; then
  echo "\n📦 Homebrew formulas: ${FORMULAS[*]}..."
  brew install "${FORMULAS[@]}"
fi

# Python via pyenv
if [[ "${SELECTED[pyenv]}" == "1" ]]; then
  LATEST_PYTHON=$(pyenv install --list | grep -E "^\s+[0-9]+\.[0-9]+\.[0-9]+$" | tail -1 | tr -d ' ')
  echo "📦 Installerer Python $LATEST_PYTHON..."
  pyenv install "$LATEST_PYTHON"
  pyenv global "$LATEST_PYTHON"
fi

# =============================================================================
# HOMEBREW CASKS
# =============================================================================
CASKS=()
[[ "${SELECTED[vscode]}" == "1" ]]          && CASKS+=(visual-studio-code)
[[ "${SELECTED[chrome]}" == "1" ]]          && CASKS+=(google-chrome)
[[ "${SELECTED[github_desktop]}" == "1" ]]  && CASKS+=(github)
[[ "${SELECTED[insomnia]}" == "1" ]]        && CASKS+=(insomnia)
[[ "${SELECTED[slack]}" == "1" ]]           && CASKS+=(slack)
[[ "${SELECTED[obsidian]}" == "1" ]]        && CASKS+=(obsidian)
[[ "${SELECTED[claude]}" == "1" ]]          && CASKS+=(claude)
[[ "${SELECTED[gcloud]}" == "1" ]]          && CASKS+=(google-cloud-sdk)

if [[ ${#CASKS[@]} -gt 0 ]]; then
  echo "\n🖥️  Apps: ${CASKS[*]}..."
  brew install --cask "${CASKS[@]}"
fi

# =============================================================================
# NODE
# =============================================================================
if [[ "${SELECTED[node]}" == "1" ]]; then
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
if [[ "${SELECTED[firebase]}" == "1" ]]; then
  echo "\n📦 firebase-tools..."
  npm install -g firebase-tools
fi

# =============================================================================
# ZSHRC
# =============================================================================
if [[ "${SELECTED[zshrc]}" == "1" ]]; then
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
if [[ "${SELECTED[gh_login]}" == "1" ]]; then
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
