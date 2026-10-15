@echo off
chcp 936 >nul
setlocal enabledelayedexpansion
rem ============================================================
rem  星购商城 starshop - 启动脚本
rem  用法：双击运行，或在 cmd 中执行 start.bat
rem  说明：本窗口会持续运行后端服务，关闭窗口即停止服务
rem ============================================================

rem 切到脚本所在目录（项目根目录），之后全部使用相对路径
cd /d %~dp0

rem ---- 0. 清掉会覆盖 Spring Boot 端口配置的环境变量（关键，勿删）----
set "SERVER__PORT="
set "SERVER__HOST="

rem ---- 1. 检查 8081 是否已在运行 ----
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
    echo [错误] 未找到 Maven。请安装 Maven 或 IntelliJ IDEA 后重试
    pause
    exit /b 1
)
echo [信息] 使用 Maven: %MVN_CMD%

rem ---- 3. 检查并初始化数据库（仅当 starshop 库不存在时执行 init.sql）----
set "MYSQL_EXE=C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
if exist "%MYSQL_EXE%" (
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
    echo [警告] 未找到 mysql 客户端，跳过数据库检查（请自行确认 starshop 库存在）
)

rem ---- 4. 编译打包（每次开机 target 目录会被清空，必须重新编译）----
echo [编译] 正在编译打包，首次运行需下载依赖，请耐心等待...
call "%MVN_CMD%" -s maven-settings.xml -DskipTests package
if errorlevel 1 (
    echo [错误] 编译失败，请检查上方 Maven 输出
    pause
    exit /b 1
)

rem ---- 5. 找到打好的 jar 并启动 ----
set "JAR_FILE="
for %%f in (target\*.jar) do set "JAR_FILE=%%f"
if not defined JAR_FILE (
    echo [错误] target 目录下未找到 jar 包
    pause
    exit /b 1
)
echo [启动] %JAR_FILE%
echo [提示] 登录页地址: http://localhost:8081/starshop-login.html
echo [提示] 测试账号: test@starshop.com / 123456
echo [提示] 本窗口持续运行服务，关闭窗口即停止；也可用 stop.bat 停止
java -jar "%JAR_FILE%"
pause
