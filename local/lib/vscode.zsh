#!/usr/bin/env zsh
# VS Code shell integration with cache-on-first-use

# Path to store the cached shell integration path
VSCODE_INTEGRATION_CACHE="${HOME}/.local/lib/vscode_shell_integration_path"

# Function to get and cache the shell integration path
function _vscode_get_integration_path() {
  # Check if VS Code is available
  if ! command -v code >/dev/null 2>&1; then
    echo "VS Code not found in PATH" >&2
    return 1
  fi
  
  # Get the shell integration path from VS Code
  local integration_path=$(code --locate-shell-integration-path zsh 2>/dev/null)
  
  # Check if we got a valid path
  if [[ -z "$integration_path" || ! -f "$integration_path" ]]; then
    echo "Failed to locate VS Code shell integration script" >&2
    return 1
  fi
  
  # Cache the path for future use
  echo "$integration_path" > "$VSCODE_INTEGRATION_CACHE"
  
  echo "$integration_path"
}

# Main function to source the VS Code shell integration
function vscode_shell_integration() {
  # Only proceed if we're in VS Code's integrated terminal
  [[ "$TERM_PROGRAM" != "vscode" ]] && return 0
  
  local integration_path=""
  
  # Try to use cached path first
  if [[ -f "$VSCODE_INTEGRATION_CACHE" ]]; then
    integration_path=$(cat "$VSCODE_INTEGRATION_CACHE")
    
    # Verify the cached path is still valid
    if [[ ! -f "$integration_path" ]]; then
      # Cache is invalid, get a fresh path
      integration_path=$(_vscode_get_integration_path)
    fi
  else
    # No cache exists, get the path
    integration_path=$(_vscode_get_integration_path)
  fi
  
  # Source the integration script if we have a valid path
  if [[ -n "$integration_path" && -f "$integration_path" ]]; then
    source "$integration_path"
  fi
}

# Run the integration function
vscode_shell_integration
