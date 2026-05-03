#!/bin/bash
# Deploy dotfiles to ~/.emacs.d/

DEST="$HOME/.emacs.d"
SRC="$HOME/repos/dotfiles/emacs"
BACKUP_DIR="$HOME/.emacs.d.bak"

# Create dated backup of existing config
if [ -d "$DEST" ]; then
    BACKUP="$BACKUP_DIR/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP"
    cp -r "$DEST"/* "$BACKUP/" 2>/dev/null
    echo "Backed up to $BACKUP"
fi

# Deploy config files
mkdir -p "$DEST/lisp"
cp "$SRC/early-init.el" "$DEST/"
cp "$SRC/init.el" "$DEST/"
cp "$SRC/lisp/"*.el "$DEST/lisp/"

echo "Deployed to $DEST"

# To sync back from ~/.emacs.d/ to the repo:
#   cp ~/.emacs.d/init.el ~/repos/dotfiles/emacs/
#   cp ~/.emacs.d/early-init.el ~/repos/dotfiles/emacs/
#   cp ~/.emacs.d/lisp/*.el ~/repos/dotfiles/emacs/lisp/
