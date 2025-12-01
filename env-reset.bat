@echo off
chcp 65001 >nul
cd /d "%~dp0"

echo ==========================================
echo       虚拟环境重置工具
echo ==========================================
echo.

:: 检测并激活虚拟环境（在 call 之前就判断，避免变量作用域问题）
if exist ".venv\Scripts\activate.bat" (
    echo 检测到虚拟环境: .venv
    call .venv\Scripts\activate.bat
    goto :ShowEnv
)

if exist "venv\Scripts\activate.bat" (
    echo 检测到虚拟环境: venv
    call venv\Scripts\activate.bat
    goto :ShowEnv
)

if exist "env\Scripts\activate.bat" (
    echo 检测到虚拟环境: env
    call env\Scripts\activate.bat
    goto :ShowEnv
)

if exist ".env\Scripts\activate.bat" (
    echo 检测到虚拟环境: .env
    call .env\Scripts\activate.bat
    goto :ShowEnv
)

:: 如果没有检测到虚拟环境，跳到警告
goto :NoVenvWarning

:ShowEnv
:: 到这里说明已经在虚拟环境中了
echo.
echo 当前 Python 环境:
echo ------------------------------------------
:: 只显示第一个 python.exe（就是当前激活的）
for /f "tokens=*" %%i in ('where python') do (
    echo %%i
    goto :ShowVersion
)

:ShowVersion
python --version
echo ------------------------------------------
echo.

:: 直接跳过警告，进入卸载流程
goto :GetPackages

:NoVenvWarning
:: 没有虚拟环境的警告
echo.
echo 当前 Python 环境:
echo ------------------------------------------
for /f "tokens=*" %%i in ('where python') do (
    echo %%i
    goto :ShowVersionGlobal
)

:ShowVersionGlobal
python --version 2>nul
if errorlevel 1 (
    echo [错误] 找不到 Python！
    pause
    exit /b 1
)
echo ------------------------------------------
echo.
echo ╔════════════════════════════════════════╗
echo ║          [警告] 危险操作！             ║
echo ╚════════════════════════════════════════╝
echo.
echo 未检测到虚拟环境！
echo 当前将操作 系统全局 Python 环境
echo.
echo 这可能会破坏系统其他 Python 程序！
echo.
echo 强烈建议:
echo   1. 现在退出 (直接关闭窗口或按 Ctrl+C)
echo   2. 创建虚拟环境: python -m venv .venv
echo   3. 再次运行此脚本
echo.
set /p CONFIRM_GLOBAL=真的要操作全局环境吗？(输入大写 YES 确认): 
if not "%CONFIRM_GLOBAL%"=="YES" (
    echo.
    echo 操作已取消，这是明智的选择！
    pause
    exit /b 0
)
echo.
echo 你已确认操作全局环境...
echo.

:GetPackages
echo ==========================================
echo       获取已安装包列表
echo ==========================================
echo.

pip freeze > temp_packages.txt 2>nul

if errorlevel 1 (
    echo [错误] 无法获取已安装包列表，pip 可能损坏
    if exist temp_packages.txt del temp_packages.txt
    pause
    exit /b 1
)

:: 检查文件是否为空
findstr /r "." temp_packages.txt >nul 2>&1
if errorlevel 1 (
    echo [提示] 环境中没有已安装的第三方包
    del temp_packages.txt
    goto :InstallBase
)

echo 当前已安装的包:
echo ------------------------------------------
type temp_packages.txt
echo ------------------------------------------
echo.

set /p CONFIRM=确认卸载以上所有包？(Y/N): 
if /i not "%CONFIRM%"=="Y" (
    echo.
    echo 操作已取消
    del temp_packages.txt
    pause
    exit /b 0
)

echo.
echo ==========================================
echo       正在卸载包...
echo ==========================================
echo.

pip uninstall -r temp_packages.txt -y

if errorlevel 1 (
    echo.
    echo [警告] 部分包卸载可能失败，继续执行...
    echo.
)

del temp_packages.txt

:InstallBase
echo.
echo ==========================================
echo       安装/升级基础包
echo ==========================================
echo.

echo [1/2] 升级 pip...
python -m pip install --upgrade pip --quiet

if errorlevel 1 (
    echo [警告] pip 升级失败，尝试继续...
)

echo [2/2] 安装 setuptools 和 wheel...
pip install --upgrade setuptools wheel --quiet

if errorlevel 1 (
    echo [错误] 基础包安装失败！
    pause
    exit /b 1
)

echo.
echo ==========================================
echo       ✓ 环境重置完成！
echo ==========================================
echo.
echo 当前环境包列表:
echo ------------------------------------------
pip list
echo ------------------------------------------
echo.

if exist "requirements.txt" (
    echo [提示] 检测到 requirements.txt 文件
    echo 可以运行 package-installer.bat 安装项目依赖
    echo.
)

echo 按任意键退出...
pause >nul
exit /b 0