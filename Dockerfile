FROM microsoft/iis
SHELL ["powershell"]
WORKDIR c:\\demo2
COPY php demo2
RUN powershell -Command \
wget http://windows.php.net/downloads/releases/php-7.1.1-Win32-VC14-x86.zip -OutFile c:\php.zip ; \
Expand-Archive -Path c:\php.zip -DestinationPath c:\php ; 
RUN powershell -Command \
	Install-WindowsFeature NET-Framework-45-ASPNET ; \  
    Install-WindowsFeature Web-Asp-Net45 ; \
    Install-WindowsFeature Web-Mgmt-Service ; \
    Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\WebManagement\Server -Name EnableRemoteManagement -Value 1 ;\
    Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\WebManagement\Server -Name RequiresWindowsCredentials -Value 0 ;\
    Set-Service -name WMSVC -StartupType Automatic ; \
    dism /online /enable-feature /featurename:IIS-CGI ; \
    Import-Module WebAdministration ; \
	c:\windows\System32\InetSrv\AppCmd set config /section:system.webServer/fastCGI /+[fullPath='c:\php\php-cgi.exe'] ; \
	c:\windows\System32\InetSrv\AppCmd set config /section:system.webServer/handlers /+[name='PHP-FastCGI',path='*.php',verb='*',modules='FastCgiModule',scriptProcessor='c:\php\php-cgi.exe',resourceType='Either'] ; \
    NET USER username "P@ssword" /ADD ; \
    NET LOCALGROUP "administrators" "username" /add ; \
	Start-service WMSVC ; 
	
RUN Remove-WebSite -Name 'Default Web Site'  
RUN New-Website -Name 'guidgenerator' -Port 80 \  
    -PhysicalPath 'c:\Demo2' -ApplicationPool '.NET v4.5'
ADD ServiceMonitor.exe /ServiceMonitor.exe
EXPOSE 80 443 8172  
ENTRYPOINT ["C:\\ServiceMonitor.exe", "w3svc"]
