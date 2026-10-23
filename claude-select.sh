#!/usr/bin/env zsh

# Unified Claude launcher with model selection
# Creates a fake `security` executable to bypass Keychain and use config.json instead

declare -A MODELS
declare -A BASE_URLS
declare -A AUTH_TOKENS
declare -A CONFIG_DIRS

# Model configurations
MODELS[1]="glm-4.6"
BASE_URLS[1]="https://api.z.ai/api/anthropic"
AUTH_TOKENS[1]="your-api-key"
CONFIG_DIRS[1]="${HOME}/.glm"

MODELS[2]="kimi-k2-thinking"
BASE_URLS[2]="https://api.kimi.com/coding"
AUTH_TOKENS[2]="your-api-key"
CONFIG_DIRS[2]="${HOME}/.kimi"

MODELS[3]="kimi-k3.1-pro"
BASE_URLS[3]="https://api.kimi.com/coding"
AUTH_TOKENS[3]="your-api-key"
CONFIG_DIRS[3]="${HOME}/.kimi"

MODELS[4]="qwen3-coder-plus"
BASE_URLS[4]="http://localhost:8317"
AUTH_TOKENS[4]="factory-api-key"
CONFIG_DIRS[4]="${HOME}/.qwen-claude"

MODELS[5]="gemini-3-pro-preview"
BASE_URLS[5]="http://localhost:8317"
AUTH_TOKENS[5]="factory-api-key"
CONFIG_DIRS[5]="${HOME}/.gemini-claude"

MODELS[6]="gpt-5.2"
BASE_URLS[6]="http://localhost:8317"
AUTH_TOKENS[6]="factory-api-key"
CONFIG_DIRS[6]="${HOME}/.claude-codex"

show_menu() {
    echo ""
    echo "   ____  _                 _        ____       _           _   "
    echo "  / ___|| | __ _ _   _  __| | ___  / ___|  ___| | ___  ___| |_ "
    echo " | |    | |/ _\` | | | |/ _\` |/ _ \ \\___ \\ / _ \\ |/ _ \\/ __| __|"
    echo " | |___ | | (_| | |_| | (_| |  __/  ___) |  __/ |  __/ (__| |_ "
    echo "  \\____||_|\\__,_|\\__,_|\\__,_|\\___| |____/ \\___|_|\\___|\\___|\\__|"
    echo ""
    echo "  Select a model:"
    echo ""
    echo "  1) GLM 4.6"
    echo "  2) Kimi K2 Thinking"
    echo "  3) Kimi K2 Thinking (alt key)"
    echo "  4) Qwen3 Coder Plus"
    echo "  5) Gemini 3 Pro Preview"
    echo "  6) Claudex"
    echo ""
    echo -n "Enter choice [1-6]: "
}

# Check for command line argument first
if [[ -n "$1" && "$1" =~ ^[1-6]$ ]]; then
    choice=$1
    shift
else
    show_menu
    read choice
fi

if [[ ! "$choice" =~ ^[1-6]$ ]]; then
    echo "Invalid selection. Exiting."
    exit 1
fi

# Create fake security executable
TEMP_DIR="${HOME}/$(uuidgen).tmp"
mkdir -p "${TEMP_DIR}"
cat << 'EOF' > "${TEMP_DIR}/security"
#!/bin/sh
echo "Keychain access denied" >&2
exit 1
EOF
chmod +x "${TEMP_DIR}/security"

# Add to PATH
export PATH="${TEMP_DIR}":$PATH

# Set environment variables based on selection
export ANTHROPIC_BASE_URL="${BASE_URLS[$choice]}"
export ANTHROPIC_AUTH_TOKEN="${AUTH_TOKENS[$choice]}"

model_name="${MODELS[$choice]}"
# Strip " (alt)" suffix for actual model name
model_name="${model_name% (alt)}"
export ANTHROPIC_DEFAULT_SONNET_MODEL="$model_name"
export ANTHROPIC_DEFAULT_OPUS_MODEL="$model_name"

export CLAUDE_CONFIG_DIR="${CONFIG_DIRS[$choice]}"
mkdir -p "${CLAUDE_CONFIG_DIR}"

echo "Launching Claude with ${MODELS[$choice]}..."
echo ""

# Run claude with remaining arguments
claude "$@"

# Cleanup
rm -rf "${TEMP_DIR}"
