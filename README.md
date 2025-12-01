# Python Environment Reset Tool | Python 环境重置工具

[English](#english) | [中文](#chinese)

---

<a name="english"></a>
## 🌟 English

### Overview

A lightweight Windows batch script tool for safely resetting Python virtual environments. It automatically detects and activates virtual environments, uninstalls all packages, and reinstalls essential base packages.

### ✨ Features

- 🔍 **Auto-Detection**: Automatically detects common virtual environment directories (`.venv`, `venv`, `env`, `.env`)
- 🛡️ **Safety First**: Warns users when operating on global Python environment
- 📦 **Clean Reset**: Uninstalls all packages and reinstalls base packages (pip, setuptools, wheel)
- 🎯 **User-Friendly**: Clear prompts and confirmations before any destructive operations
- 🌐 **UTF-8 Support**: Properly handles Chinese and other Unicode characters

### 📋 Requirements

- Windows OS
- Python 3.x installed and accessible via `python` command
- pip package manager

### 🚀 Quick Start

1. **Download** the `env-reset.bat` file
2. **Place** it in your Python project root directory (where your virtual environment folder is)
3. **Run** by double-clicking `env-reset.bat` or executing it in command prompt

```batch
env-reset.bat
```

### 📖 Usage

#### For Virtual Environment (Recommended)

```bash
# Create a virtual environment first (if you haven't)
python -m venv .venv

# Run the reset tool
env-reset.bat
```

The script will:
1. Detect and activate your virtual environment
2. List all installed packages
3. Ask for confirmation
4. Uninstall all packages
5. Upgrade pip and install base packages

#### For Global Environment (Not Recommended)

If no virtual environment is detected, the script will:
1. Display a **strong warning**
2. Require explicit confirmation (type `YES` in uppercase)
3. Proceed only if confirmed

### 🔧 Supported Virtual Environment Names

- `.venv` (recommended)
- `venv`
- `env`
- `.env`

### ⚠️ Important Notes

- **Always use virtual environments** for project development
- The script will **not** delete the virtual environment folder itself
- Base packages (pip, setuptools, wheel) are automatically reinstalled
- If `requirements.txt` exists, you'll be reminded to reinstall project dependencies

### 📝 Example Output

```
==========================================
      虚拟环境重置工具
==========================================

检测到虚拟环境: .venv

当前 Python 环境:
------------------------------------------
C:\Project\.venv\Scripts\python.exe
Python 3.11.0
------------------------------------------

==========================================
      获取已安装包列表
==========================================

当前已安装的包:
------------------------------------------
requests==2.31.0
numpy==1.24.0
------------------------------------------

确认卸载以上所有包？(Y/N): Y

==========================================
      ✓ 环境重置完成！
==========================================
```

### 🤝 Contributing

Contributions, issues, and feature requests are welcome!

### 📄 License

MIT License - feel free to use this tool in your projects.

### 👤 Author

Created with ❤️ for Python developers

---

<a name="chinese"></a>
## 🌟 中文

### 项目简介

一个轻量级的 Windows 批处理脚本工具，用于安全地重置 Python 虚拟环境。它能自动检测并激活虚拟环境，卸载所有包，并重新安装必要的基础包。

### ✨ 功能特性

- 🔍 **自动检测**：自动检测常见的虚拟环境目录（`.venv`、`venv`、`env`、`.env`）
- 🛡️ **安全优先**：在操作全局 Python 环境时会发出强烈警告
- 📦 **彻底清理**：卸载所有包并重新安装基础包（pip、setuptools、wheel）
- 🎯 **用户友好**：在执行任何破坏性操作前都有清晰的提示和确认
- 🌐 **UTF-8 支持**：正确处理中文和其他 Unicode 字符

### 📋 系统要求

- Windows 操作系统
- 已安装 Python 3.x 并可通过 `python` 命令访问
- pip 包管理器

### 🚀 快速开始

1. **下载** `env-reset.bat` 文件
2. **放置** 到你的 Python 项目根目录（虚拟环境文件夹所在位置）
3. **运行** 双击 `env-reset.bat` 或在命令提示符中执行

```batch
env-reset.bat
```

### 📖 使用方法

#### 虚拟环境模式（推荐）

```bash
# 首先创建虚拟环境（如果还没有）
python -m venv .venv

# 运行重置工具
env-reset.bat
```

脚本将会：
1. 检测并激活你的虚拟环境
2. 列出所有已安装的包
3. 请求确认
4. 卸载所有包
5. 升级 pip 并安装基础包

#### 全局环境模式（不推荐）

如果未检测到虚拟环境，脚本将：
1. 显示**强烈警告**
2. 要求明确确认（输入大写的 `YES`）
3. 仅在确认后才继续执行

### 🔧 支持的虚拟环境名称

- `.venv`（推荐）
- `venv`
- `env`
- `.env`

### ⚠️ 重要提示

- **始终使用虚拟环境**进行项目开发
- 脚本**不会**删除虚拟环境文件夹本身
- 基础包（pip、setuptools、wheel）会自动重新安装
- 如果存在 `requirements.txt`，会提醒你重新安装项目依赖

### 📝 输出示例

```
==========================================
      虚拟环境重置工具
==========================================

检测到虚拟环境: .venv

当前 Python 环境:
------------------------------------------
C:\Project\.venv\Scripts\python.exe
Python 3.11.0
------------------------------------------

==========================================
      获取已安装包列表
==========================================

当前已安装的包:
------------------------------------------
requests==2.31.0
numpy==1.24.0
------------------------------------------

确认卸载以上所有包？(Y/N): Y

==========================================
      ✓ 环境重置完成！
==========================================
```

### 🤝 贡献

欢迎贡献代码、提出问题和功能请求！

### 📄 许可证

MIT 许可证 - 可自由在你的项目中使用此工具。

### 👤 作者

用 ❤️ 为 Python 开发者创建

---

## 🌐 Links

- [Report Bug](../../issues)
- [Request Feature](../../issues)

## ⭐ Star History

If you find this tool helpful, please consider giving it a star!