#!/usr/bin/env bash
# dothething installer — downloads dtt into ~/.local/bin and makes sure that
# directory is on your PATH (it is by default on macOS, but not on most Linux
# distros). Usage:  curl -fsSL dotheth.ing/install.sh | bash
set -euo pipefail

SRC="${DTT_INSTALL_SRC:-https://dotheth.ing/dtt.sh}"
BIN_DIR="$HOME/.local/bin"
DEST="$BIN_DIR/dtt"

mkdir -p "$BIN_DIR"
echo "▸ Downloading dothething → $DEST" >&2
curl -fsSL "$SRC" -o "$DEST"

# Sanity-check we actually got the script, not an error/redirect page.
if ! head -1 "$DEST" | grep -q '^#!/usr/bin/env bash'; then
    rm -f "$DEST"
    echo "✗ Download didn't look like the dtt script. Aborting." >&2
    exit 1
fi
chmod +x "$DEST"

case ":$PATH:" in
    *":$BIN_DIR:"*)
        echo "✓ Installed. $BIN_DIR is already on your PATH — just run: dtt" >&2
        ;;
    *)
        # Pick the startup file for the user's login shell (we're running under
        # `bash` via the pipe, so detect via $SHELL, not $BASH_VERSION).
        case "$(basename "${SHELL:-sh}")" in
            zsh)  rc="$HOME/.zshrc" ;;
            bash) rc="$HOME/.bashrc" ;;
            *)    rc="$HOME/.profile" ;;
        esac
        line='export PATH="$HOME/.local/bin:$PATH"'
        if ! { [ -f "$rc" ] && grep -qF "$line" "$rc"; }; then
            printf '\n# Added by the dothething installer\n%s\n' "$line" >> "$rc"
        fi
        echo "✓ Installed to $DEST" >&2
        echo "✓ Added ~/.local/bin to your PATH in $rc" >&2
        echo "" >&2
        echo "  Open a new terminal (or run:  source $rc), then run:  dtt" >&2
        ;;
esac
