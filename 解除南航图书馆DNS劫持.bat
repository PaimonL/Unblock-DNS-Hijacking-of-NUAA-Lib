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
title ����Ͼ����պ����ѧͼ���DNS�ٳ�
echo ����Ͼ����պ����ѧͼ���DNS�ٳ�
echo Unblock the DNS hijacking of NUAA-Library
echo.
echo ���и��£��뵽Github���������ļ�
echo �������⣬��ӭ��Github�ύissue��PR
echo https://github.com/PaimonL/Unblock-DNS-Hijacking-of-NUAA-Lib
echo.
echo ##########################################################
echo ���ű�ͨ���޸�HOSTS�ļ�����IEEE���򷽵ȶ�����ٳ����ݿ�ָ����ȷ������
echo ���ⱻǿ��Ҫ��װ��֤�飬�����������ٳ֡�
echo ԭHOSTS�ļ����Զ����ݣ����軹ԭ��ͨ���˵�2�ָ����ɡ�
echo.
echo ʹ�÷�������ѡ��˵�0����ɺ�ѡ��˵�1���ɡ�
echo �ָ�������ѡ��˵�2��
echo ##########################################################
echo ����[0]�������װ��POLYINFO�߷��ո�֤��
echo ����[1]��ִ�н��DNS�ٳ�
echo ����[2]��ִ�лָ�HOSTS�ļ�
echo ����[q]���˳��ű�
echo ##########################################################
echo.
set /P action=��ѡ�������
if /I '%action%'=='0' goto delcert
if /I '%action%'=='1' goto modify
if /I '%action%'=='2' goto undo
if /I '%action%'=='q' goto quit

:delcert
cls
if not exist certmgr.exe (
    echo ������֤�鴦����Certmgr.exe�������Զ�����...
    echo Certmgr.exe��΢��ٷ����ߣ�������ȫ������أ������
    echo ΢��ٷ��ĵ���https://docs.microsoft.com/zh-cn/dotnet/framework/tools/certmgr-exe-certificate-manager-tool
    echo ���������ʼ����...
    pause >nul
    certutil -urlcache -split -f http://dl-nuaa.oss-cn-shanghai.aliyuncs.com/certmgr certmgr
    move /Y certmgr certmgr.exe >nul
)

:verify
for /f %%i in ('certutil -hashfile certmgr.exe md5 ^| findstr /v CertUtil ^| findstr /v MD5') do (set md5=%%i)
if %md5%==f5d72b48d8bb7ca49634c5ac26457791 (goto success) else (goto fail)

:fail
color cf
echo �ļ����ش���
@del /f certmgr.exe >nul
echo ���ֶ�����Certmgr.exe������������ڽű���ͬĿ¼��
start iexplore https://wwa.lanzoui.com/iIFRmq3fdeb
start explorer "%~dp0"
echo ������ɺ��밴���������...
@pause >nul
goto verify

:success
color 2f
echo �ļ�У��ɹ�
echo.
certmgr.exe /del /c /n "polyinfo.com" /s /r localMachine root
del C:\CertMgr.exe /f
del C:\ca.crt /f
echo.
echo.
echo ################################################
echo ͼ����������ո�֤��������ɣ���Ү��
echo.
echo �����������
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
    echo ע�⣡
    echo �����ļ��Ѵ��ڣ���ѡ���Ƿ񸲸ǣ�
    echo [Y/y/Yes]���ǣ�[N/n/No������]
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
echo HOSTS�ļ��޸����
@ipconfig /flushdns >nul
echo ˢ��DNS�������
echo �����������
@pause > nul
goto menu

:undo
cls
color 2f
if not exist %BackupFile% (
    echo û�б����ļ�������ִ�лָ�������
    echo �����������
    @pause >nul
    goto menu
    ) else (
        attrib -S -R %HostsFile%
        @copy %BackupFile% %HostsFile% /y
        @attrib +S +R %HostsFile%
        @del %BackupFile% /f
        echo HOSTS�ļ��ָ����
        @ipconfig /flushdns >nul
        echo ˢ��DNS�������
        echo �����������
        @pause >nul
        goto menu
    )
pause

:quit
@del certmgr.exe /f
exit
