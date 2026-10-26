@echo off
chcp 936 >nul
setlocal
rem ============================================================
rem  星购商城 starshop - 停止脚本
rem  按 8081 端口找到监听进程并结束
rem ============================================================

set "FOUND="
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":8081 " ^| findstr "LISTENING"') do (
    set "FOUND=1"
    echo [停止] 正在结束进程 PID=%%a ...
    taskkill /F /PID %%a >nul 2>nul
)
if defined FOUND (
    echo [完成] 服务已停止
) else (
    echo [提示] 8081 端口没有正在运行的服务
)
pause
