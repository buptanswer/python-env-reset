# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Windows batch script tool for safely resetting Python virtual environments. The tool automatically detects common virtual environment directories, uninstalls all packages, and reinstalls essential base packages (pip, setuptools, wheel).

**Key characteristics:**
- Single-file batch script (`env-reset.bat`)
- Bilingual interface (Chinese/English)
- UTF-8 encoded for international character support
- Safety-first design with multiple confirmation steps

## Core Script Architecture

The `env-reset.bat` script follows a state-machine pattern with labeled sections using batch `goto` statements:

1. **Initialization** (lines 1-4): Enable delayed expansion, set UTF-8 encoding, change to script directory
2. **Virtual Environment Detection** (lines 11-37): Checks for `.venv`, `venv`, `env`, `.env` in order
3. **Environment Display** (`:ShowEnv`, `:ShowVersion`): Shows activated venv details, sets `SELECTED_PYTHON=python`
4. **Global Warning** (`:NoVenvWarning`): Strong warnings when no venv detected
5. **Python Version Selection** (`:SelectPythonVersion`, lines 107-214): NEW in v1.1.0
   - Detects all Python installations using `where python` and `py -0p`
   - Deduplicates findings via `:CheckDuplicate` subroutine
   - Auto-selects if only one version found
   - Prompts user selection for multiple versions
   - Sets `SELECTED_PYTHON` to chosen Python executable path
6. **Package Enumeration** (`:GetPackages`): Uses `pip freeze` to list packages
7. **Uninstallation** (lines 270+): Batch uninstall via temp file
8. **Base Package Installation** (`:InstallBase`): Reinstalls pip, setuptools, wheel

**Critical implementation details:**
- `setlocal EnableDelayedExpansion` at line 2 enables delayed expansion for entire script
- Virtual environment activation happens BEFORE `goto` to avoid variable scope issues
- `SELECTED_PYTHON` variable stores the Python interpreter path throughout script execution
- All `python` and `pip` commands use `!SELECTED_PYTHON!` with delayed expansion
- All pip operations use `"!SELECTED_PYTHON!" -m pip` for version-specific execution
- `where python` shows current Python path (first result only for cleanliness)
- Global environment operations require typing "YES" (uppercase, exact match)
- Temp files: `temp_packages.txt` (package list), `temp_python_list.txt` (detected Pythons), `temp_python_list.txt.dedup` (deduplicated)

## Testing the Script

**Manual testing workflow:**
1. Create a test virtual environment: `python -m venv .venv`
2. Install some packages: `.venv\Scripts\activate && pip install requests numpy`
3. Run the script: `env-reset.bat`
4. Verify only base packages remain: `pip list`

**Test scenarios to cover:**
- Virtual environment with packages (normal case)
- Empty virtual environment (should skip to base package installation)
- No virtual environment with single Python installation (should auto-select)
- No virtual environment with multiple Python installations (should prompt for selection)
- Different venv names (`.venv`, `venv`, `env`, `.env`)
- Broken pip (error handling verification)
- Invalid user input during version selection (input validation)

**Version selection testing:**
- Test with only one Python in PATH: should auto-select without prompting
- Test with multiple Python versions: should display list and accept numeric input
- Test invalid selection input: should re-prompt with error message
- Test selection out of range: should re-prompt with error message

## Working with Batch Scripts

**When modifying `env-reset.bat`:**
- Preserve UTF-8 encoding (`chcp 65001`)
- Maintain bilingual output (Chinese primary, context for English)
- **IMPORTANT**: Always use `!SELECTED_PYTHON!` for python/pip commands (delayed expansion)
- Test all `goto` label paths to avoid dead code
- Use `errorlevel` checks after critical operations (pip, file operations)
- Keep temp file cleanup in all code paths
- Validate changes don't break variable scoping
- When adding new Python version detection methods, update `:SelectPythonVersion`
- Ensure `SELECTED_PYTHON` is set in both venv and global paths

**Batch scripting gotchas in this codebase:**
- `setlocal EnableDelayedExpansion` is required at script start for `!var!` syntax
- Variables set inside `call`ed scripts may not persist - hence early detection logic
- `for /f` loops: use `!var!` for variables modified within the loop
- `if errorlevel 1` means "if errorlevel >= 1" (not "if errorlevel == 1")
- `>nul 2>&1` suppresses both stdout and stderr
- `/i` flag makes string comparisons case-insensitive
- When extracting tokens from `for /f`, `tokens=*` gets entire line, `tokens=1,2` gets first two space-delimited tokens
- `for %%x in (!LINE!)` iterates over space-separated tokens, last assignment wins (used to get last token)
- Always quote paths in delayed expansion: `"!SELECTED_PYTHON!"` not `!SELECTED_PYTHON!`

## File Structure

- `env-reset.bat` - Main executable script (333 lines, v1.1.0)
- `README.md` - Bilingual documentation with usage examples
- `CHANGELOG.md` - Version history (currently v1.1.0)
- `CLAUDE.md` - This file, guidance for Claude Code
- `LICENSE` - MIT license
- `.gitignore` - Standard git ignore patterns

**Major version changes:**
- v1.0.0 (197 lines): Initial release with basic venv reset
- v1.1.0 (333 lines): Added multi-Python version detection and selection (+136 lines)

This is a simple, single-purpose tool with no dependencies beyond Windows and Python 3.x.
