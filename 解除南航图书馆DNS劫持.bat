@echo off
if exist "%SystemRoot%\SysWOW64" path %path%;%windir%\SysNative;%SystemRoot%\SysWOW64;%~dp0
bcdedit >nul
if '%errorlevel%' NEQ '0' (goto UACPrompt) else (goto UACAdmin)
:UACPrompt
%1 start "" mshta vbscript:createobject("shell.application").shellexecute("""%~0""","::",,"runas",1)(window.close)&exit
exit /B
:UACAdmin
cd /d "%~dp0"

SET BackupFile=%Windir%\system32\drivers\etc\hosts.nuaalib.bak
SET HostsFile=%Windir%\System32\drivers\etc\hosts
SET TempFile=%temp%\hosts.nuaalib.temp

:menu
cls
color 1f
title 解除南京航空航天大学图书馆DNS劫持
echo 解除南京航空航天大学图书馆DNS劫持
echo Unblock the DNS hijacking of NUAA-Library
echo.
echo 如有更新，请到Github下载最新文件
echo 如有问题，欢迎到Github提交issue或PR
echo https://github.com/PaimonL/Unblock-DNS-Hijacking-of-NUAA-Lib
echo.
echo ##########################################################
echo 本脚本通过修改HOSTS文件，将IEEE和万方等多个被劫持数据库指向正确解析。
echo 避免被强制要求安装根证书，导致流量被劫持。
echo 原HOSTS文件会自动备份，如需还原，通过菜单2恢复即可。
echo.
echo 使用方法：先选择菜单0，完成后选择菜单1即可。
echo 恢复方法：选择菜单2。
echo ##########################################################
echo 输入[0]，清除安装的POLYINFO高风险根证书
echo 输入[1]，执行解除DNS劫持
echo 输入[2]，执行恢复HOSTS文件
echo 输入[q]，退出脚本
echo ##########################################################
echo.
set /P action=请选择操作：
if /I '%action%'=='0' goto delcert
if /I '%action%'=='1' goto modify
if /I '%action%'=='2' goto undo
if /I '%action%'=='q' goto quit

:delcert
cls
if not exist certmgr.exe (
    echo 不存在证书处理工具Certmgr.exe，即将自动下载...
    echo Certmgr.exe是微软官方工具，如遇安全软件拦截，请放行
    echo 微软官方文档：https://docs.microsoft.com/zh-cn/dotnet/framework/tools/certmgr-exe-certificate-manager-tool
    echo 按任意键开始下载...
    pause >nul
    certutil -urlcache -split -f http://dl-nuaa.oss-cn-shanghai.aliyuncs.com/certmgr certmgr
    move /Y certmgr certmgr.exe >nul
)

:verify
for /f %%i in ('certutil -hashfile certmgr.exe md5 ^| findstr /v CertUtil ^| findstr /v MD5') do (set md5=%%i)
if %md5%==f5d72b48d8bb7ca49634c5ac26457791 (goto success) else (goto fail)

:fail
color cf
echo 文件下载错误！
@del /f certmgr.exe >nul
echo 请手动下载Certmgr.exe，并将程序放在脚本相同目录下
start iexplore https://wwa.lanzoui.com/iIFRmq3fdeb
start explorer "%~dp0"
echo 下载完成后请按任意键继续...
@pause >nul
goto verify

:success
color 2f
echo 文件校验成功
echo.
certmgr.exe /del /c /n "polyinfo.com" /s /r localMachine root
del C:\CertMgr.exe /f
del C:\ca.crt /f
echo.
echo.
echo ################################################
echo 图书馆垃圾风险根证书清理完成！好耶！
echo.
echo 按任意键返回
@pause >nul
goto menu

:modify
cls
@attrib -S -R %HostsFile%
if not exist %BackupFile% (
    color 2f
    @copy %HostsFile% %BackupFile% /y
) else (
    color cf
    echo 注意！
    echo 备份文件已存在，请选择是否覆盖？
    echo [Y/y/Yes]覆盖，[N/n/No不覆盖]
    @copy %HostsFile% %BackupFile% /-y >nul
)
color 2f
if exist %TempFile% @del %TempFile% /f >nul
findstr /v "NUAA-Library ieee.org wanfangdata.com.cn vers.cqvip.com airitilibrary.cn ebscohost.com" %HostsFile% >> %TempFile%
echo. >>%TempFile%
echo. >>%TempFile%
@echo # Unblock the DNS hijacking of NUAA-Library BEGIN >>%TempFile%
@echo 23.192.245.54 ieeexplore.ieee.org >>%TempFile%
@echo 23.64.185.112 www.ieee.org >>%TempFile%
@echo 122.115.55.6 wanfangdata.com.cn >>%TempFile%
@echo 122.115.55.6 www.wanfangdata.com.cn >>%TempFile%
@echo 52.83.120.240 vers.cqvip.com >>%TempFile%
@echo 103.242.173.18 airitilibrary.cn >>%TempFile%
@echo 103.242.173.18 www.airitilibrary.cn >>%TempFile%
@echo 140.234.254.11 search.ebscohost.com >>%TempFile%
@echo 140.234.252.103 ebscohost.com >>%TempFile%
>>%TempFile% set /p="# Unblock the DNS hijacking of NUAA-Library END" <nul
@copy %TempFile% %HostsFile% /y >nul
@del %TempFile% /f >nul
@attrib +S +R %HostsFile%
echo HOSTS文件修改完成
@ipconfig /flushdns >nul
echo 刷新DNS缓存完成
echo 按任意键返回
@pause > nul
goto menu

:undo
cls
color 2f
if not exist %BackupFile% (
    echo 没有备份文件，无需执行恢复操作！
    echo 按任意键返回
    @pause >nul
    goto menu
    ) else (
        attrib -S -R %HostsFile%
        @copy %BackupFile% %HostsFile% /y
        @attrib +S +R %HostsFile%
        @del %BackupFile% /f
        echo HOSTS文件恢复完成
        @ipconfig /flushdns >nul
        echo 刷新DNS缓存完成
        echo 按任意键返回
        @pause >nul
        goto menu
    )
pause

:quit
@del certmgr.exe /f
exit
