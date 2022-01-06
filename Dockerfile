FROM mcr.microsoft.com/windows/servercore:ltsc2019

ENV ACCEPT_EULA="_"
ENV SA_PASSWORD="_"
ENV SA_PASSWORD_PATH="C:\ProgramData\Docker\secrets\sa-password"
ENV ATTACH_DBS="[]"

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
WORKDIR /

ADD https://go.microsoft.com/fwlink/?linkid=829176 C:\\sqlexpress.exe
RUN Start-Process -Wait -FilePath .\sqlexpress.exe -ArgumentList /qs, /x:setup
RUN .\setup\setup.exe /q /ACTION=Install /INSTANCENAME=SQLEXPRESS /FEATURES=SQL,AS /UPDATEENABLED=0 /SQLSVCACCOUNT='NT AUTHORITY\System' /SQLSYSADMINACCOUNTS='BUILTIN\ADMINISTRATORS' /TCPENABLED=1 /NPENABLED=0 /IACCEPTSQLSERVERLICENSETERMS
RUN Remove-Item -Recurse -Force sqlexpress.exe, setup

RUN stop-service MSSQL`$SQLEXPRESS
RUN set-itemproperty -path 'HKLM:\software\microsoft\microsoft sql server\mssql14.SQLEXPRESS\mssqlserver\supersocketnetlib\tcp\ipall' -name tcpdynamicports -value ''
RUN set-itemproperty -path 'HKLM:\software\microsoft\microsoft sql server\mssql14.SQLEXPRESS\mssqlserver\supersocketnetlib\tcp\ipall' -name tcpport -value 1433
RUN set-itemproperty -path 'HKLM:\software\microsoft\microsoft sql server\mssql14.SQLEXPRESS\mssqlserver\' -name LoginMode -value 2
CMD start-service MSSQL`$SQLEXPRESS