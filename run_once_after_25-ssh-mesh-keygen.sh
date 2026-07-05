#!/bin/sh
# Generate this machine's SSH-mesh keypair if it doesn't exist yet, then print the
# public + host keys to add to the r9os fleet registry. The registry
# (r9os/references/ssh-fleet.json) holds topology and is private, so it can't live in
# this public repo — a human/agent pastes the two public values below into it, commits,
# and runs `ssh-fleet-sync` on every machine. Public keys are not secrets.

KEY="$HOME/.ssh/id_ed25519"
if [ -f "$KEY" ]; then
  exit 0
fi

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
ssh-keygen -t ed25519 -f "$KEY" -N "" -C "$(whoami)@$(scutil --get LocalHostName 2>/dev/null || hostname -s)"
chmod 600 "$KEY"; chmod 644 "$KEY.pub"

echo ""
echo "=========================================================================="
echo " SSH-mesh key generated. To join the fleet, add this machine to the r9os"
echo " registry (r9os/references/ssh-fleet.json), commit, then run ssh-fleet-sync"
echo " on every machine:"
echo "--------------------------------------------------------------------------"
echo "   localHostName: $(scutil --get LocalHostName 2>/dev/null)"
echo "   pubkey:  $(cat "$KEY.pub")"
echo "   hostkey: $(awk '{print $1, $2}' /etc/ssh/ssh_host_ed25519_key.pub 2>/dev/null)"
echo "=========================================================================="
echo ""
