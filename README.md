# Audio Device Switcher NG — Plasma 6

A Plasma 6 audio-device switcher based on [mertemr/plasma6-audio-device-switcher-ng](https://github.com/mertemr/plasma6-audio-device-switcher-ng).

This fork keeps the original widget behavior while adding Plasma 6 fixes and options.

## Changes in this fork

### 1.0.2

- Adds **Show virtual devices** under **Configure → General**.
- Virtual sinks/sources such as **Virtual Surround Sink** remain hidden by default.
- When enabled, virtual audio sinks and sources are included in the device buttons.

### 1.0.1

- Fixes device-name tooltips flashing briefly and immediately disappearing under Plasma 6 / Qt 6.
- Uses Qt Quick Controls' attached `ToolTip` properties directly on each `ToolButton`.
- Uses a 500 ms tooltip delay and keeps the tooltip visible while the pointer remains over the device.

## Install

```bash
git clone https://github.com/newnetmp3/plasma6-audio-device-switcher-ng.git
cd plasma6-audio-device-switcher-ng
./install.sh
```

If you already have the widget installed, the installer upgrades it in place.

You can also install directly from the package directory:

```bash
kpackagetool6 --type Plasma/Applet --install package
```

or upgrade an existing installation:

```bash
kpackagetool6 --type Plasma/Applet --upgrade package
```

Restart Plasma if needed:

```bash
systemctl --user restart plasma-plasmashell.service
```

## Upstream and attribution

This project is derived from `mertemr/plasma6-audio-device-switcher-ng` and retains the original author attribution in the Plasma metadata and source headers.

## License

GPL, matching the upstream project and source headers.
