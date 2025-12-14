# 🎉 Python Environment Reset Tool v1.1.0

> A lightweight Windows tool for safely resetting Python virtual environments with multi-version support

## ✨ Highlights

🔍 **Smart Detection** - Automatically finds and activates your virtual environment
🐍 **Multi-Version Support** - Detects all Python installations and lets you choose (NEW!)
🛡️ **Safety First** - Strong warnings and confirmations before any changes
📦 **Complete Reset** - Clean uninstall of all packages + fresh base installation
🌐 **UTF-8 Support** - Perfect handling of Chinese and international characters

## 🚀 Quick Start

1. Download `env-reset.bat`
2. Place in your project directory
3. Double-click to run
4. Follow the prompts

## 📦 What's New in v1.1.0

### 🆕 Major Feature: Multi-Python Version Detection

When operating on the global environment, the tool now:

- ✨ **Auto-detects all Python installations** using both `where python` and Python Launcher (`py -0p`)
- 🎯 **Smart selection**: Auto-uses the only version if just one is found
- 📋 **Interactive choice**: Shows a numbered list when multiple versions exist
- ✅ **Input validation**: Ensures you pick a valid version number
- 🔒 **Precise control**: Reset only the Python version you actually want

### 🔧 Technical Improvements

- All pip operations now use `python -m pip` for version-specific execution
- Enhanced script reliability with delayed variable expansion
- Automatic deduplication of detected Python paths
- Improved error handling throughout the script

### 📈 Growth

- Script expanded from 197 to 333 lines (+68% for better functionality)
- Added comprehensive documentation in CLAUDE.md
- Updated bilingual README with detailed usage scenarios

## 💡 Perfect For

- Cleaning up messy virtual environments
- Managing multiple Python versions on your system
- Troubleshooting package conflicts
- Starting fresh without recreating venv
- Testing clean installations across different Python versions

## ⚠️ Safety Features

- **Global environment protection** - Requires typing `YES` to operate on system Python
- **Version confirmation** - Shows selected Python path and version before proceeding
- **Multiple confirmations** - Shows package list before uninstalling
- **Non-destructive** - Doesn't delete the venv folder itself

## 📖 Example Workflow

### With Virtual Environment (Unchanged)
```batch
# Your venv is detected automatically
> env-reset.bat
检测到虚拟环境: .venv
当前 Python 环境: C:\Project\.venv\Scripts\python.exe
# Continues normally...
```

### With Multiple Python Versions (NEW!)
```batch
> env-reset.bat
# No venv detected, shows warning
真的要操作全局环境吗？(输入大写 YES 确认): YES

检测到以下 Python 版本:
------------------------------------------
[1] C:\Users\User\AppData\Local\Programs\Python\Python312\python.exe
    Python 3.12.0
[2] C:\Users\User\AppData\Local\Programs\Python\Python311\python.exe
    Python 3.11.5
------------------------------------------

请选择 Python 版本 [1-2]: 1

已选择: C:\Users\User\AppData\Local\Programs\Python\Python312\python.exe
Python 3.12.0
# Continues with selected version...
```

## 📖 Documentation

Full documentation available in [README.md](README.md) with both English and Chinese versions.

See [CHANGELOG.md](CHANGELOG.md) for complete version history.

## 🤝 Contributing

Issues, feature requests, and pull requests are welcome!

## 📄 License

MIT License - Free to use in your projects

---

**Download the `env-reset.bat` file below and start cleaning up your Python environments! 🐍✨**

If you find this useful, please ⭐ star the repository!