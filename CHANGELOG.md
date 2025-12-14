# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2025-12-15

### Added
- 🐍 **Multi-Python Version Detection and Selection**
  - Automatically detects all Python installations using both `where python` and Python Launcher (`py -0p`)
  - Allows users to select which Python version to reset when operating on global environment
  - Automatic deduplication of detected Python paths
  - Single-version auto-selection when only one Python installation is found
- ✨ Enhanced global environment workflow with version selection
- 🔧 Enabled delayed variable expansion for improved script reliability

### Changed
- All `python` and `pip` commands now use the selected Python version
- Improved script robustness with consistent use of delayed expansion variables
- Enhanced Python path extraction from `py -0p` output

### Technical Details
- Added `:SelectPythonVersion` subroutine for multi-version detection
- Added `:CheckDuplicate` subroutine for removing duplicate Python paths
- Modified all pip operations to use `python -m pip` for version-specific execution
- Introduced `SELECTED_PYTHON` variable to track the chosen Python interpreter

## [1.0.0] - 2025-12-02

### Added
- 🎉 Initial release of Python Environment Reset Tool
- ✨ Automatic virtual environment detection (`.venv`, `venv`, `env`, `.env`)
- 🛡️ Safety warnings for global Python environment operations
- 📦 Complete package uninstallation with user confirmation
- 🔧 Automatic base packages installation (pip, setuptools, wheel)
- 🌐 Full UTF-8 support for international characters
- 📝 Clear and informative console output
- ⚠️ Error handling and validation
- 🎯 User-friendly prompts and confirmations
- 📋 Display of current Python environment and installed packages
- 💡 Helpful hints for requirements.txt installation

### Features
- Detects and activates virtual environments automatically
- Lists all installed packages before uninstallation
- Requires explicit confirmation before destructive operations
- Upgrades pip to the latest version
- Installs essential build tools (setuptools, wheel)
- Shows final package list after reset
- Provides guidance for next steps

### Security
- Strong warnings when operating on global Python environment
- Requires typing "YES" in uppercase for global environment operations
- Multiple confirmation steps to prevent accidental data loss

---

## Release Notes

### What's New in v1.0.0

This is the first stable release of the Python Environment Reset Tool! 🎊

**Key Highlights:**
- Simple one-click solution to reset your Python virtual environment
- Smart detection of common virtual environment folder names
- Safety-first approach with multiple warnings and confirmations
- Clean, professional console interface with UTF-8 support
- Automatic reinstallation of essential Python packages

**Perfect for:**
- Developers who need to clean up their virtual environments
- Troubleshooting package conflicts
- Starting fresh with a clean Python environment
- Testing package installations

**Getting Started:**
1. Download `env-reset.bat`
2. Place it in your project directory
3. Double-click to run
4. Follow the prompts

Thank you for using Python Environment Reset Tool! 🐍✨