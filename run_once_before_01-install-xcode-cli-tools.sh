#!/bin/bash
set -e

if xcode-select -p &>/dev/null; then
    exit 0
fi

echo "Installing Xcode Command Line Tools..."
xcode-select --install

echo "Waiting for installation to complete..."
until xcode-select -p &>/dev/null; do
    sleep 5
done
