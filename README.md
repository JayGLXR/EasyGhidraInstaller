# EasyGhidraInstaller (MacOS)

A simple, powerful script to automate the installation of Ghidra as a native macOS application.

## Overview

EasyGhidraInstaller is a bash script that makes it easy to install Ghidra (NSA's reverse engineering tool) on macOS. It handles everything from downloading the latest version to creating a proper macOS application bundle that integrates seamlessly with your dock.

**Features:**
- Downloads the latest version of Ghidra directly from the official source
- Extracts and sets up Ghidra in your Applications folder
- Creates a proper macOS application bundle (.app)
- Adds Ghidra to your dock for easy access
- Verifies Java dependencies and offers installation help
- Works on both Intel and Apple Silicon Macs

## Requirements

- macOS 10.15 or later
- Internet connection (if downloading Ghidra)
- Terminal access
- Administrator privileges

## Installation

### Quick Install (Recommended)

1. Open Terminal
2. Run the following command:

```bash
curl -fsSL https://raw.githubusercontent.com/yourusername/EasyGhidraInstaller/main/install.sh | bash
```

### Manual Install

1. Clone this repository:
```bash
git clone https://github.com/yourusername/EasyGhidraInstaller.git
```

2. Make the script executable:
```bash
chmod +x EasyGhidraInstaller/easy-ghidra-installer.sh
```

3. Run the script:
```bash
./EasyGhidraInstaller/easy-ghidra-installer.sh
```

## Options

The script provides several options:

- `-d, --download-only`: Download Ghidra without installing
- `-f, --force`: Force reinstallation even if Ghidra is already installed
- `-p, --path <path>`: Specify a custom installation path
- `-h, --help`: Display help information
- `-v, --version`: Display version information

## Usage Examples

### Basic Installation
```bash
./easy-ghidra-installer.sh
```

### Install to a Custom Location
```bash
./easy-ghidra-installer.sh -p ~/Applications
```

### Force Reinstallation
```bash
./easy-ghidra-installer.sh -f
```

## Java Requirements

Ghidra requires Java Development Kit (JDK) 17 or later. The script will check if you have Java installed and offer to install it via Homebrew if needed.

## Apple Silicon (M1/M2/M3) Support

Ghidra runs on Apple Silicon Macs through the Rosetta 2 translation layer. The script automatically handles this for you.

## Troubleshooting

### Java Issues

If you encounter Java-related errors:

1. Make sure you have JDK 17+ installed:
```bash
brew install openjdk@17
```

2. Set the JAVA_HOME environment variable in your `.zshrc` or `.bash_profile`:
```bash
echo 'export JAVA_HOME=$(/usr/libexec/java_home)' >> ~/.zshrc
source ~/.zshrc
```

### Permission Issues

If you encounter permission errors:

```bash
sudo ./easy-ghidra-installer.sh
```

### Application Won't Open

If Ghidra won't open due to security settings:

1. Go to System Preferences > Security & Privacy > General
2. Click "Open Anyway" for Ghidra
3. Try launching Ghidra again

## Uninstallation

To uninstall Ghidra and remove all related files:

```bash
./easy-ghidra-installer.sh --uninstall
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- The National Security Agency (NSA) for creating Ghidra
- All contributors who have helped improve this installer

## Disclaimer

This project is not affiliated with or endorsed by the NSA or the Ghidra project. Use at your own risk.
