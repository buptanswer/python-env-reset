@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
cd /d "%~dp0"

echo.
echo  ============================================
echo       Python Env Reset Tool  v1.2.0
echo  ============================================
echo.

:: 检测并激活虚拟环境（在 call 之前就判断，避免变量作用域问题）
if exist ".venv\Scripts\activate.bat" (
    echo  [OK] Virtual env found: .venv
    call .venv\Scripts\activate.bat
    goto :ShowEnv
)

if exist "venv\Scripts\activate.bat" (
    echo  [OK] Virtual env found: venv
    call venv\Scripts\activate.bat
    goto :ShowEnv
)

if exist "env\Scripts\activate.bat" (
    echo  [OK] Virtual env found: env
    call env\Scripts\activate.bat
    goto :ShowEnv
)

if exist ".env\Scripts\activate.bat" (
    echo  [OK] Virtual env found: .env
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
echo  Current Python:
echo  ------------------------------------------
:: 只显示第一个 python.exe（就是当前激活的）
for /f "tokens=*" %%i in ('where python') do (
    echo  %%i
    goto :ShowVersion
)

:ShowVersion
for /f "tokens=*" %%v in ('"!SELECTED_PYTHON!" --version 2^>^&1') do echo  %%v
echo  ------------------------------------------
echo.

:: 直接跳过警告，进入卸载流程
goto :GetPackages

:NoVenvWarning
:: 没有虚拟环境的警告
echo.
echo  Current Python:
echo  ------------------------------------------
for /f "tokens=*" %%i in ('where python') do (
    echo  %%i
    goto :ShowVersionGlobal
)

:ShowVersionGlobal
for /f "tokens=*" %%v in ('python --version 2^>^&1') do echo  %%v
if errorlevel 1 (
    echo  [ERROR] Python not found.
    pause
    exit /b 1
)
echo  ------------------------------------------
echo.
echo  ##########################################
echo  ##                                      ##
echo  ##         [WARNING] DANGER              ##
echo  ##                                      ##
echo  ##########################################
echo.
echo  WARNING: No virtual environment detected.
echo  You are about to operate on the GLOBAL Python environment.
echo.
echo  This may break other Python programs on the system.
echo.
echo  Recommended:
echo    1. Exit now (close window or press Ctrl+C)
echo    2. Create venv: python -m venv .venv
echo    3. Run this script again
echo.
set /p CONFIRM_GLOBAL=Operate on global env? (type YES to confirm): 
if not "%CONFIRM_GLOBAL%"=="YES" (
    echo.
    echo  Cancelled. Good choice.
    pause
    exit /b 0
)
echo.
echo  Confirmed. Proceeding with global environment...
echo.

:: 检测并选择 Python 版本
goto :SelectPythonVersion

:SelectPythonVersion
echo  --------------------------------------------
echo       Detect Python Versions
echo  --------------------------------------------
echo.

:: 创建临时文件存储Python路径
set TEMP_PYTHON_LIST=temp_python_list.txt
if exist "%TEMP_PYTHON_LIST%" del "%TEMP_PYTHON_LIST%"

:: 方法1: 使用 where python 获取 PATH 中的所有 python.exe
where python >nul 2>&1
if not errorlevel 1 (
    for /f "tokens=*" %%i in ('where python 2^>nul') do (
        >>"%TEMP_PYTHON_LIST%" echo %%i
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
            >>"%TEMP_PYTHON_LIST%" echo !PYTHON_PATH!
        )
    )
)

:: 检查是否找到任何 Python 版本
if not exist "%TEMP_PYTHON_LIST%" (
    echo  [ERROR] No Python installation found.
    pause
    exit /b 1
)

:: 去重并编号显示
echo  Available Python versions:
echo  ------------------------------------------
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
    echo  Only one Python found: !SELECTED_PYTHON!
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
    echo  [!INDEX!] %%i
    "%%i" --version 2>nul | findstr /r "Python" >nul
    if not errorlevel 1 (
        for /f "tokens=*" %%v in ('"%%i" --version 2^>^&1') do echo       %%v
    )
)
echo  ------------------------------------------
echo.

:AskVersion
set /p PYTHON_CHOICE= Select Python version [1-%TOTAL%]: 

:: 验证输入
echo %PYTHON_CHOICE%| findstr /r "^[0-9][0-9]*$" >nul
if errorlevel 1 (
    echo  [ERROR] Please enter a valid number.
    goto :AskVersion
)

if %PYTHON_CHOICE% LSS 1 (
    echo  [ERROR] Please enter a number between 1 and %TOTAL%.
    goto :AskVersion
)

if %PYTHON_CHOICE% GTR %TOTAL% (
    echo  [ERROR] Please enter a number between 1 and %TOTAL%.
    goto :AskVersion
)

:: 获取选定的 Python 路径
call set "SELECTED_PYTHON=%%PYTHON_PATH_%PYTHON_CHOICE%%%"

echo.
echo  Selected: !SELECTED_PYTHON!
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
    >>"%TEMP_PYTHON_LIST%.dedup" echo %CHECK_PATH%
    set /a TOTAL+=1
)
exit /b

:GetPackages
echo  --------------------------------------------
echo       Get Installed Packages
echo  --------------------------------------------
echo.

"!SELECTED_PYTHON!" -m pip freeze > temp_packages_raw.txt 2>nul

if errorlevel 1 (
    echo  [ERROR] Cannot get package list, pip may be broken.
    if exist temp_packages_raw.txt del temp_packages_raw.txt
    pause
    exit /b 1
)

:: 分离可编辑安装包（-e 开头的行）和常规包
if exist temp_packages.txt del temp_packages.txt
if exist temp_editable.txt del temp_editable.txt

:: 过滤出常规包（非 -e 开头）
findstr /v /b /c:"-e " temp_packages_raw.txt > temp_packages.txt 2>nul
:: 获取可编辑安装的包名（使用 pip list --editable）
"!SELECTED_PYTHON!" -m pip list --editable --format=freeze > temp_editable.txt 2>nul

del temp_packages_raw.txt >nul 2>&1

:: 检查是否有常规包
set HAS_PACKAGES=0
findstr /r "." temp_packages.txt >nul 2>&1
if not errorlevel 1 set HAS_PACKAGES=1

:: 检查是否有可编辑包
set HAS_EDITABLE=0
findstr /r "." temp_editable.txt >nul 2>&1
if not errorlevel 1 set HAS_EDITABLE=1

if !HAS_PACKAGES!==0 if !HAS_EDITABLE!==0 (
    echo  [INFO] No third-party packages installed.
    del temp_packages.txt >nul 2>&1
    del temp_editable.txt >nul 2>&1
    goto :InstallBase
)

echo  Installed packages:
echo  ------------------------------------------
if !HAS_PACKAGES!==1 type temp_packages.txt
if !HAS_EDITABLE!==1 (
    echo.
    echo  [Editable packages]:
    type temp_editable.txt
)
echo  ------------------------------------------
echo.

set /p CONFIRM= Uninstall all packages above? (Y/N): 
if /i not "%CONFIRM%"=="Y" (
    echo.
    echo  Cancelled.
    del temp_packages.txt >nul 2>&1
    del temp_editable.txt >nul 2>&1
    pause
    exit /b 0
)

echo.
echo  --------------------------------------------
echo       Uninstalling Packages...
echo  --------------------------------------------
echo.

:: 先卸载可编辑安装的包（按包名逐个卸载）
if !HAS_EDITABLE!==1 (
    echo  Uninstalling editable packages...
    for /f "tokens=1 delims==" %%p in (temp_editable.txt) do (
        "!SELECTED_PYTHON!" -m pip uninstall %%p -y
    )
    echo.
)

:: 卸载常规包
if !HAS_PACKAGES!==1 (
    "!SELECTED_PYTHON!" -m pip uninstall -r temp_packages.txt -y

    if errorlevel 1 (
        echo.
        echo  [WARNING] Some packages may have failed to uninstall. Continuing...
        echo.
    )
)

del temp_packages.txt >nul 2>&1
del temp_editable.txt >nul 2>&1

:InstallBase
echo.
echo  --------------------------------------------
echo       Install/Upgrade Base Packages
echo  --------------------------------------------
echo.

echo  [1/2] Upgrading pip...
"!SELECTED_PYTHON!" -m pip install --upgrade pip --quiet

if errorlevel 1 (
    echo  [WARNING] pip upgrade failed, continuing...
)

echo  [2/2] Installing setuptools and wheel...
"!SELECTED_PYTHON!" -m pip install --upgrade setuptools wheel --quiet

if errorlevel 1 (
    echo  [ERROR] Base package installation failed.
    pause
    exit /b 1
)

echo.
echo  ============================================
echo       [OK] Environment reset complete.
echo  ============================================
echo.
echo  Current packages:
echo  ------------------------------------------
"!SELECTED_PYTHON!" -m pip list
echo  ------------------------------------------
echo.

if exist "requirements.txt" (
    echo  [INFO] requirements.txt found.
    echo  Run package-installer.bat to install dependencies.
    echo.
)

echo  Press any key to exit...
pause >nul
exit /b 0