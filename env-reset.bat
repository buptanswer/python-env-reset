@echo off
setlocal EnableDelayedExpansion
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
:: 虚拟环境中直接使用 python 命令
set "SELECTED_PYTHON=python"
echo.
echo 当前 Python 环境:
echo ------------------------------------------
:: 只显示第一个 python.exe（就是当前激活的）
for /f "tokens=*" %%i in ('where python') do (
    echo %%i
    goto :ShowVersion
)

:ShowVersion
!SELECTED_PYTHON! --version
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

:: 检测并选择 Python 版本
goto :SelectPythonVersion

:SelectPythonVersion
echo ==========================================
echo       检测 Python 版本
echo ==========================================
echo.

:: 创建临时文件存储Python路径
set TEMP_PYTHON_LIST=temp_python_list.txt
if exist "%TEMP_PYTHON_LIST%" del "%TEMP_PYTHON_LIST%"

:: 方法1: 使用 where python 获取 PATH 中的所有 python.exe
where python >nul 2>&1
if not errorlevel 1 (
    for /f "tokens=*" %%i in ('where python 2^>nul') do (
        echo %%i >> "%TEMP_PYTHON_LIST%"
    )
)

:: 方法2: 使用 py launcher 获取所有已安装的 Python 版本
py -0p >nul 2>&1
if not errorlevel 1 (
    for /f "tokens=*" %%i in ('py -0p 2^>nul') do (
        set "LINE=%%i"
        :: 提取最后一个token (Python路径)
        for %%p in (!LINE!) do set "PYTHON_PATH=%%p"
        :: 检查是否是.exe文件
        echo !PYTHON_PATH! | findstr /i "\.exe$" >nul
        if not errorlevel 1 (
            echo !PYTHON_PATH! >> "%TEMP_PYTHON_LIST%"
        )
    )
)

:: 检查是否找到任何 Python 版本
if not exist "%TEMP_PYTHON_LIST%" (
    echo [错误] 未找到任何 Python 安装！
    pause
    exit /b 1
)

:: 去重并编号显示
echo 检测到以下 Python 版本:
echo ------------------------------------------
set INDEX=0
set TOTAL=0

:: 先计算总数并去重
for /f "usebackq tokens=*" %%i in ("%TEMP_PYTHON_LIST%") do (
    set "CURRENT_PATH=%%i"
    call :CheckDuplicate "!CURRENT_PATH!"
)

:: 如果只有一个版本，直接使用
if %TOTAL%==1 (
    for /f "usebackq tokens=*" %%i in ("%TEMP_PYTHON_LIST%.dedup") do (
        set "SELECTED_PYTHON=%%i"
    )
    echo.
    echo 检测到唯一 Python 版本: !SELECTED_PYTHON!
    "!SELECTED_PYTHON!" --version 2>nul
    echo.
    del "%TEMP_PYTHON_LIST%" >nul 2>&1
    del "%TEMP_PYTHON_LIST%.dedup" >nul 2>&1
    goto :GetPackages
)

:: 显示所有版本供用户选择
set INDEX=0
for /f "usebackq tokens=*" %%i in ("%TEMP_PYTHON_LIST%.dedup") do (
    set /a INDEX+=1
    set "PYTHON_PATH_!INDEX!=%%i"
    echo [!INDEX!] %%i
    "%%i" --version 2>nul | findstr /r "Python" >nul
    if not errorlevel 1 (
        for /f "tokens=*" %%v in ('"%%i" --version 2^>^&1') do echo     %%v
    )
)
echo ------------------------------------------
echo.

:AskVersion
set /p PYTHON_CHOICE=请选择 Python 版本 [1-%TOTAL%]:

:: 验证输入
echo %PYTHON_CHOICE%| findstr /r "^[0-9][0-9]*$" >nul
if errorlevel 1 (
    echo [错误] 请输入有效的数字！
    goto :AskVersion
)

if %PYTHON_CHOICE% LSS 1 (
    echo [错误] 请输入 1 到 %TOTAL% 之间的数字！
    goto :AskVersion
)

if %PYTHON_CHOICE% GTR %TOTAL% (
    echo [错误] 请输入 1 到 %TOTAL% 之间的数字！
    goto :AskVersion
)

:: 获取选定的 Python 路径
call set "SELECTED_PYTHON=%%PYTHON_PATH_%PYTHON_CHOICE%%%"

echo.
echo 已选择: !SELECTED_PYTHON!
"!SELECTED_PYTHON!" --version
echo.

:: 清理临时文件
del "%TEMP_PYTHON_LIST%" >nul 2>&1
del "%TEMP_PYTHON_LIST%.dedup" >nul 2>&1

goto :GetPackages

:CheckDuplicate
set "CHECK_PATH=%~1"
set "IS_DUP=0"

if exist "%TEMP_PYTHON_LIST%.dedup" (
    for /f "usebackq tokens=*" %%d in ("%TEMP_PYTHON_LIST%.dedup") do (
        if /i "%%d"=="%CHECK_PATH%" set "IS_DUP=1"
    )
)

if !IS_DUP!==0 (
    echo %CHECK_PATH% >> "%TEMP_PYTHON_LIST%.dedup"
    set /a TOTAL+=1
)
exit /b

:GetPackages
echo ==========================================
echo       获取已安装包列表
echo ==========================================
echo.

"!SELECTED_PYTHON!" -m pip freeze > temp_packages.txt 2>nul

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

"!SELECTED_PYTHON!" -m pip uninstall -r temp_packages.txt -y

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
"!SELECTED_PYTHON!" -m pip install --upgrade pip --quiet

if errorlevel 1 (
    echo [警告] pip 升级失败，尝试继续...
)

echo [2/2] 安装 setuptools 和 wheel...
"!SELECTED_PYTHON!" -m pip install --upgrade setuptools wheel --quiet

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
"!SELECTED_PYTHON!" -m pip list
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