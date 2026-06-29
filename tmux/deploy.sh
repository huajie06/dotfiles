#!/bin/bash
# Deploy tmux config to ~/.config/tmux/tmux.conf

DEST_DIR="$HOME/.config/tmux"
SRC="$HOME/repos/dotfiles/tmux/tmux.conf"
BACKUP_DIR="$HOME/.config/tmux.bak"

if [ -f "$DEST_DIR/tmux.conf" ]; then
    mkdir -p "$BACKUP_DIR"
    cp "$DEST_DIR/tmux.conf" "$BACKUP_DIR/tmux.conf.$(date +%Y%m%d_%H%M%S)"
    echo "Backed up to $BACKUP_DIR"
fi

mkdir -p "$DEST_DIR"
cp "$SRC" "$DEST_DIR/tmux.conf"
echo "Deployed tmux config to $DEST_DIR/tmux.conf"
