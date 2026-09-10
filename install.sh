#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PKG="$HERE/package"
ID="org.kde.plasma.audiodeviceswitcher-ng"

if ! command -v kpackagetool6 >/dev/null 2>&1; then
    echo "kpackagetool6 not found."
    exit 1
fi

echo "Upgrading $ID..."
if kpackagetool6 --type Plasma/Applet --show "$ID" >/dev/null 2>&1; then
    kpackagetool6 --type Plasma/Applet --upgrade "$PKG"
else
    kpackagetool6 --type Plasma/Applet --install "$PKG"
fi

systemctl --user restart plasma-plasmashell.service
echo "Installed Audio Device Switcher NG 1.0.2."
