# aarch64dwm

aarch64dwm is a customized clone of [dwm](https://dwm.suckless.org/), specifically tailored for **AArch64 (ARM64) devices**, including the **Raspberry Pi** and compatible operating systems. It retains all the core functionality of the original dwm but includes minor adaptations for better compatibility on ARM-based hardware.

## Features
- Lightweight and minimal tiling window manager
- Optimized for **AArch64** architecture
- Compatible with **Raspberry Pi OS (64-bit)** and other ARM64-based Linux distributions
- Custom additions for improved hardware compatibility

## Installation

### Prerequisites
Ensure you have the necessary dependencies installed:
```sh
sudo apt update && sudo apt install -y xorg libx11-dev libxft-dev libxinerama-dev
```

### Cloning and Compiling
```sh
git clone https://github.com/your-repo/aarch64dwm.git
cd aarch64dwm
make
sudo make install
```

### Running aarch64dwm
To start **aarch64dwm**, add the following line to your `.xinitrc`:
```sh
exec dwm
```
Then, start X:
```sh
startx
```

## Configuration
Like the original **dwm**, customization is done via modifying `config.h` and recompiling:
```sh
vim config.h  # Make necessary changes
make && sudo make install
```

## Keybindings
(Default dwm keybindings apply)
- `Mod + Shift + Enter` – Open terminal
- `Mod + p` – dmenu (application launcher)
- `Mod + Shift + c` – Close window
- `Mod + 1-9` – Switch between workspaces
- `Mod + Shift + q` – Quit X session

## Notes
- aarch64dwm does **not** introduce significant changes to the original **dwm**.
- This version is mainly for ensuring smoother operation on **Raspberry Pi OS** and similar ARM64 distributions.
- Consider using a **lightweight status bar** like `slstatus` for system information.

## License
As a clone of **dwm**, aarch64dwm is released under the **MIT/X License**.

## Credits
- **suckless.org** for the original dwm
- Raspberry Pi community for ARM64 optimizations


