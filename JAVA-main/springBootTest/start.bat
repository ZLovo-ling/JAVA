@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
rem ============================================================
rem  星购商城 starshop - 启动脚本
rem  用法：双击运行，或在 cmd 里执行 start.bat
rem  说明：会启动一个后台服务，关闭窗口即停止服务
rem ============================================================

rem 切到脚本所在目录（即项目根目录），之后全部使用相对路径
cd /d %~dp0

rem ---- 0. 清除可能覆盖 Spring Boot 端口配置的环境变量 ----
set "SERVER__PORT="
set "SERVER__HOST="

rem ---- 0.5 自动定位 JDK 17（优先用我们安装的 JDK 17）----
set "JAVA_HOME="
if exist "D:\Java\jdk-17.0.20.1+1\bin\java.exe" (
    set "JAVA_HOME=D:\Java\jdk-17.0.20.1+1"
) else (
    where java.exe >nul 2>nul
    if not errorlevel 1 set "JAVA_HOME="
)
if defined JAVA_HOME (
    set "PATH=%JAVA_HOME%\bin;%PATH%"
    echo [信息] 使用 JDK: %JAVA_HOME%
) else (
    echo [警告] 未找到 JDK 17，将使用系统默认 java（若报错请安装 JDK 17）
)
where java.exe >nul 2>nul
if errorlevel 1 (
    echo [错误] 未找到 java，请先安装 JDK 17 或配置 JAVA_HOME
    pause
    exit /b 1
)

rem ---- 1. 检查 8081 是否已被占用 ----
netstat -ano | findstr ":8081 " | findstr "LISTENING" >nul 2>nul
if not errorlevel 1 (
    echo [提示] 8081 端口已有服务在运行，无需重复启动
    echo        如需重启请先运行 stop.bat
    pause
    exit /b 0
)

rem ---- 2. 定位 Maven（优先 PATH，其次 IDEA 自带）----
set "MVN_CMD="
where mvn.cmd >nul 2>nul
if not errorlevel 1 set "MVN_CMD=mvn.cmd"
if not defined MVN_CMD (
    if exist "D:\IntelliJ IDEA 2024.3.2.2\plugins\maven\lib\maven3\bin\mvn.cmd" (
        set "MVN_CMD=D:\IntelliJ IDEA 2024.3.2.2\plugins\maven\lib\maven3\bin\mvn.cmd"
    )
)
if not defined MVN_CMD (
    echo [错误] 未找到 Maven，请安装 Maven 或 IntelliJ IDEA
    pause
    exit /b 1
)
echo [信息] 使用 Maven: %MVN_CMD%

rem ---- 3. 检查并初始化数据库（若 starshop 库不存在时执行 init.sql）----
set "MYSQL_EXE="
if exist "C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe" set "MYSQL_EXE=C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe"
if not defined MYSQL_EXE (
    if exist "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" set "MYSQL_EXE=C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
)
if defined MYSQL_EXE (
    "%MYSQL_EXE%" --default-character-set=utf8mb4 -u root -p123456 -e "USE starshop" >nul 2>nul
    if errorlevel 1 (
        echo [初始化] 未检测到 starshop 数据库，开始执行 sql\init.sql ...
        "%MYSQL_EXE%" --default-character-set=utf8mb4 -u root -p123456 < sql\init.sql
        if errorlevel 1 (
            echo [错误] 数据库初始化失败，请确认 MySQL 服务已启动、账号 root 密码 123456
            pause
            exit /b 1
        )
        echo [初始化] 数据库创建完成
    ) else (
        echo [信息] 数据库 starshop 已存在，跳过初始化
    )
) else (
    echo [警告] 未找到 mysql 客户端，跳过数据库检查（请确保 starshop 库已存在）
)

rem ---- 4. 编译打包（每次启动都会重新编译）----
echo [编译] 正在编译打包，首次较慢请耐心等待...
call "%MVN_CMD%" -s maven-settings.xml -DskipTests package
if errorlevel 1 (
    echo [错误] 编译失败，请查看上方 Maven 报错
    pause
    exit /b 1
)

rem ---- 5. 找到打好的 jar 包并启动 ----
set "JAR_FILE="
for %%f in (target\*.jar) do set "JAR_FILE=%%f"
if not defined JAR_FILE (
    echo [错误] target 目录中未找到 jar 包
    pause
    exit /b 1
)
echo [启动] %JAR_FILE%
echo [提示] 登录页地址: http://localhost:8081/starshop-login.html
echo [提示] 测试账号: test@starshop.com / 123456
echo [提示] 服务在前台运行，关闭本窗口即停止服务，也可运行 stop.bat 停止
java -jar "%JAR_FILE%"
pause
