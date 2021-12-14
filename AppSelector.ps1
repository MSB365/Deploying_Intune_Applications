#region Description
<#     
       .NOTES
       ==============================================================================
       Created on:         2021/09/08 
       Created by:         Sandro Schmocker | Drago Petrovic
       Organization:       ITpoint Systems AG | MSB365 Blog
       Filename:           AppSelector.ps1
       Current version:    V1.11     

       Find us on:
             * Website:         https://www.itpoint.ch (SaSc) | https://www.msb365.blog (DrPe)
             * Technet:         https://social.technet.microsoft.com/Profile/MSB365 (DrPe)
             * LinkedIn:        https://www.linkedin.com/in/drago-petrovic/ (DrPe)
             * MVP Profile:     https://mvp.microsoft.com/de-de/PublicProfile/5003446 (DrPe)
       ==============================================================================

       .DESCRIPTION
       This script can be executed without prior customisation.
       This script is used to create different Packages for Intune.
       All variables that are required are queried by the script.
       This script creates the following App elements for Intune:
            - Adobe Acrobat Reader DC (.intunewin)
			- App Installer (.intunewin)
			- Citrix Workspace (.intunewin)
			- Company Portal (.intunewin)
			- Firefox (.intunewin)
			- Forti VPN Client (.intunewin)
			- Google Chrome (.intunewin)
       

       .NOTES
       All packages will be created as (.intunewin) files that can be uploaded to Microsoft Intune.





       .EXAMPLE
       .\AppSelector.ps1 
             

       .COPYRIGHT
       Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), 
       to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
       and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

       The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

       THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
       FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
       WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
       ===========================================================================
       .CHANGE LOG
             V1.00, 2021/12/08 - SaSc - Initial version
             V1.10, 2021/12/13 - DrPe - Optimizing Script with "IF/THEN"			 




--- keep it simple, but significant ---

#>
#endregion



cls
Write-host "Welcome to the App Selector" -ForegroundColor Magenta
Write-Host ""
pause
cls

Write-Host ""
Write-Host "First we need to Download the sources from Github" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press Enter to Confirm or cancel the Script to leave" -ForegroundColor Cyan
Write-Host ""
pause


#region create Log file for logging
$mdmdirectory = "C:\MDM\AppSelector"
write-host "Checking if Directory $mdmdirectory exists... " -ForegroundColor Magenta
Start-Sleep -s 1
If ((Test-Path -Path $mdmdirectory) -eq $false)
{
    try{
        Write-Host "$mdmdirectory does not exist..." -ForegroundColor Cyan
        Start-Sleep -s 1
        Write-Host "Creating $mdmdirectory directory..." -ForegroundColor Cyan
        New-Item -Path $mdmdirectory -ItemType directory -ErrorAction Stop
        Start-Sleep -s 2
        Write-Host "Directory $mdmdirectory created!" -ForegroundColor Green
    }catch{
        throw "Could not create folder ""$mdmdirectory"" for logs. " + $_
        Return
    }
        
}
Start-Sleep -s 1
Write-Host "Directory $mdmdirectory present!" -ForegroundColor Green
Start-Sleep -s 3




write-host "Checking if App Files from Github already exists... " -ForegroundColor Magenta
Start-Sleep -s 2
$zippathfile = "C:\MDM\AppSelector\Applications\App_Selector_V1.1.ps1"
Test-Path -Path $zippathfile -PathType Leaf


If ((Test-Path -Path $zippathfile -PathType Leaf) -eq $false)
{
    try{
        $Location = "$mdmdirectory"
$Name = "applications"
Write-Host "Downloading ZIP File from Github to $mdmdirectory directory..." -ForegroundColor Cyan
Start-Sleep -s 2
    # Force to create a zip file 
    $ZipFile = "$mdmdirectory\$Name.zip"
    New-Item $ZipFile -ItemType File -Force
 
    $RepositoryZipUrl = "https://github.com/sschmocker/intune_app_deployment/archive/refs/heads/main.zip"
    #$RepositoryZipUrl = "https://github.com/sschmocker/intune_app_deployment"

    # download the zip 
    Write-Host 'Starting downloading the GitHub Repository'
    Invoke-RestMethod -Uri $RepositoryZipUrl -OutFile $ZipFile
    Write-Host 'Download finished' -ForegroundColor Green
    start-sleep -s 2


    #Extract Zip File
    Write-Host "Extracting ZIP File in $mdmdirectory directory..." -ForegroundColor Cyan
    start-sleep -s 1
    Write-Host 'Starting unzipping the GitHub Repository locally' -ForegroundColor Gray
    start-sleep -s 1
    Expand-Archive -Path $ZipFile -DestinationPath $mdmdirectory -Force
    start-sleep -s 1
    Write-Host 'Unzip finished' -ForegroundColor Green
    start-sleep -s 2
    

    # remove the zip file
    Write-Host "Removing ZIP File from $mdmdirectory directory..." -ForegroundColor Cyan
    start-sleep -s 2
    Remove-Item -Path $ZipFile -Force
    Write-Host 'Done!' -ForegroundColor Green
    start-sleep -s 2

    #Rename Folder
    Write-Host "Rename directory from $mdmdirectory to $mdmdirectory\intune_app_deployment-main..." -ForegroundColor Cyan
    start-sleep -s 1
    Rename-Item "$mdmdirectory\intune_app_deployment-main" -NewName "Applications"
    start-sleep -s 1
    Write-Host 'Directory renamed!' -ForegroundColor Green
    start-sleep -s 3
    }catch{
        throw "Could not create folder ""$mdmdirectory"" for logs. " + $_
        Return
    }
        
}
else {
Write-Host 'Files already in the directory $mdmdirectory exists' -BackgroundColor Yellow -ForegroundColor Black
start-sleep -s 3
}

Write-Host "Sources have been downloaded and saved under $mdmdirectory\Applications" -ForegroundColor Gray 
Start-Sleep -s 3
#cls

Write-Host "All pre Tasks are set" -ForegroundColor Gray 
Start-Sleep -s 2
Write-Host "Initialisation of the Intune Package Builder" -ForegroundColor Magenta
Start-Sleep -s 4


$customer = $(Write-Host "Please insert customer name. Example: " -NoNewLine) + $(Write-Host """" -NoNewline) +$(Write-Host "Contoso" -ForegroundColor Yellow -NoNewline; Read-Host """")
$AppSelectorSources = "C:\MDM\AppSelector\Applications\Sources"
$AppSelectorSourcesfinal = "C:\MDM\AppSelector\Applications"
$outputDirectory = "$AppSelectorSourcesfinal\Output_Files_for_Intune\$customer"

function Show-Menu
{
    param (
        [string]$Title = 'App Selector'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "Select the apps you want to install"
    Write-Host ""
    Write-Host "1: Adobe Acrobat Reader DC"
    Write-Host "2: App Installer (Mandatory)"
    Write-Host "3: Citrix Workspace"
    Write-Host "4: Company Portal (Mandatory)"
    Write-Host "5: Firefox"
    Write-Host "6: FortiClient"
    Write-Host "7: Google Chrome"
    Write-Host "8: All Apps"
    Write-Host ""
    Write-Host "Q: Press 'Q' to quit."
}


do
 {
     Show-Menu
     $selection = Read-Host "Please make a selection"
     switch ($selection)
     {
         '1' {
            'You chose Adobe Acrobat Reader DC'
            write-host "Config of Package starts now"
            timeout 3
            ######ADOBE#####
            cd $AppSelectorSources
            ./IntuneWinAppUtil -c "$AppSelectorSources\AdobeReader\AdobeReader_Source" -s "Adobe Reader DC.txt" -o "$outputDirectory" -q
            Write-Host "Config have been safed under $outputDirectory" -foregroundcolor Green
         }
         
         '2' {
            'You chose App installer'
            write-host "Config of Package starts now"
            timeout 3
            ######App Installer#####
            cd $AppSelectorSources
            ./IntuneWinAppUtil -c "$AppSelectorSources\AppInstaller_Win32\AppInstaller_Source" -s "Microsoft Desktop App Installer.ps1" -o "$outputDirectory" -q
            Write-Host "Config have been safed under $outputDirectory" -foregroundcolor Green
         }
         
         '3' {
            'You chose Citrix Workspace'
            write-host "Config of Package starts now"
            timeout 3
            ######Citrix#####
            cd $AppSelectorSources
            ./IntuneWinAppUtil -c "$AppSelectorSources\CitrixWorkspace\CitrixWorkspace_Source" -s "Citrix Workspace.txt" -o "$outputDirectory" -q
            Write-Host "Config have been safed under $outputDirectory" -foregroundcolor Green
         }
         
         '4' {
            'You chose Company Portal'
            write-host "Config of Package starts now"
            timeout 3
            ######CompanyPortal#####
            cd $AppSelectorSources
            ./IntuneWinAppUtil -c "$AppSelectorSources\CompanyPortal\CompanyPortal_Source" -s "Microsoft Company Portal.ps1" -o "$outputDirectory" -q
            Write-Host "Config have been safed under $outputDirectory" -foregroundcolor Green
         }
         
         '5' {
            'You chose Firefox'
            write-host "Config of Package starts now"
            timeout 3             
            ######FireFox#########
            cd $AppSelectorSources
            .\IntuneWinAppUtil -c "$AppSelectorSources\MozillaFirefox\MozillaFirefox_Source" -s "MozillaFirefox.txt" -o "$outputDirectory" -q
            Write-Host "Config have been safed under $outputDirectory" -foregroundcolor Green            
         }
         
         '6' {
            'You chose FortiClient'
            write-host "Config of Package starts now"
            timeout 3
            ######FortiClient#####
            cd $AppSelectorSources
            ./IntuneWinAppUtil -c "$AppSelectorSources\FortiClient_SSL_VPN\FortiClient_Source" -s "FortiClient_SSL_VPN.txt" -o "$outputDirectory" -q



#------------------------------------------------------------------------------------------------------------------#
####################################################FORTI CONFIG####################################################
#------------------------------------------------------------------------------------------------------------------#


            $sourceFolderForti = "$AppSelectorSources\FortiClient_SSL_VPN_configuration\$customer\FortiClient_Source_configuration"


            #Variables for Customer VPN Tunnel#
            $tunnelName = Read-Host "insert Name for VPN Tunnel"
            $tunnelDescription = Read-Host "insert Description for VPN Tunnel"
            $vpnServer = Read-Host "insert VPN Server Adress"
            cls

            #Create ConfigFolder for specified Customer#
            if (!(Test-Path -path $sourceFolderForti)) {New-Item $sourceFolderForti -Type Directory}
            Copy-Item "$AppSelectorSources\FortiClient_SSL_VPN_configuration\FortiClient_Source_Configuration\*" -Destination $sourceFolderForti -Force
            cls

#Write Config for Registry to file#
$script=@"
           if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels\$tunnelName") -ne $true) {  New-Item "HKLM:\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels\$tunnelName" -force -ea SilentlyContinue };
            New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels\$tunnelName' -Name 'Description' -Value '$tunnelDescription' -PropertyType String -Force -ea SilentlyContinue;
            New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels\$tunnelName' -Name 'Server' -Value '$vpnServer' -PropertyType String -Force -ea SilentlyContinue;
            New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels\$tunnelName' -Name 'promptusername' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;
"@


            New-Item -Path "$sourceFolderForti" -Name "FortiClient_SSL_VPN_regKeys.ps1" -Force -Value $script


            cls
            cd "C:\intune\Applications\Sources"
            ./IntuneWinAppUtil -c "$sourceFolderForti" -s "FortiClient_SSL_VPN_Config.ps1" -o "$outputDirectory" -q
            Write-Host "Config have been safed under $outputDirectory" -foregroundcolor Green
            cls



#-----------------------------------------------------------------------------------------------------------------#
###################################################################################################################
#-----------------------------------------------------------------------------------------------------------------#



         }
         
         '7' {
            'You chose Google Chrome'
            write-host "Config of Package starts now"
            timeout 3
            ######Google Chrome######
            cd $AppSelectorSources
            ./IntuneWinAppUtil -c "$AppSelectorSources\GoogleChrome\GoogleChrome_Source" -s "Google Chrome.txt" -o "$outputDirectory" -q
           Write-Host "Config have been safed under $outputDirectory" -foregroundcolor Green
         }
         
         '8' {
             'You chose All Apps, this process takes some time
             Please be patient.'
             timeout 4
             
             cls
             ######ADOBE#####
             cd $AppSelectorSources
             ./IntuneWinAppUtil -c "$AppSelectorSources\AdobeReader\AdobeReader_Source" -s "Adobe Reader DC.txt" -o "$outputDirectory" -q
             cls

             ######App Installer#####
             cd $AppSelectorSources
             ./IntuneWinAppUtil -c "$AppSelectorSources\AppInstaller_Win32\AppInstaller_Source" -s "Microsoft Desktop App Installer.ps1" -o "$outputDirectory" -q
             cls

             ######Citrix#####
             cd $AppSelectorSources
             ./IntuneWinAppUtil -c "$AppSelectorSources\CitrixWorkspace\CitrixWorkspace_Source" -s "Citrix Workspace.txt" -o "$outputDirectory" -q
             cls

             ######CompanyPortal#####
             cd $AppSelectorSources
             ./IntuneWinAppUtil -c "$AppSelectorSources\CompanyPortal\CompanyPortal_Source" -s "Microsoft Company Portal.ps1" -o "$outputDirectory" -q
             cls
             
             ######FireFox#########
             cd $AppSelectorSources
             .\IntuneWinAppUtil -c "$AppSelectorSources\MozillaFirefox\MozillaFirefox_Source" -s "MozillaFirefox.txt" -o "$outputDirectory" -q
             cls

             ######FortiClient#####
             cd $AppSelectorSources
             ./IntuneWinAppUtil -c "$AppSelectorSources\FortiClient_SSL_VPN\FortiClient_Source" -s "FortiClient_SSL_VPN.txt" -o "$outputDirectory" -q
             cls

#------------------------------------------------------------------------------------------------------------------#
####################################################FORTI CONFIG####################################################
#------------------------------------------------------------------------------------------------------------------#


            $sourceFolderForti = "$AppSelectorSources\FortiClient_SSL_VPN_configuration\$customer\FortiClient_Source_configuration"


            #Variables for Customer VPN Tunnel#
            Write-Host "You need to specify the needed variables for the VPN Tunnel in FortiClient"
            pause
            cls
            $tunnelName = Read-Host "insert Name for VPN Tunnel"
            $tunnelDescription = Read-Host "insert Description for VPN Tunnel"
            $vpnServer = Read-Host "insert VPN Server Adress"
            cls

            #Create ConfigFolder for specified Customer#
            if (!(Test-Path -path $sourceFolderForti)) {New-Item $sourceFolderForti -Type Directory}
            Copy-Item "$AppSelectorSources\FortiClient_SSL_VPN_configuration\FortiClient_Source_Configuration\*" -Destination $sourceFolderForti -Force
            cls

#Write Config for Registry to file#
$script=@"
           if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels\$tunnelName") -ne $true) {  New-Item "HKLM:\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels\$tunnelName" -force -ea SilentlyContinue };
            New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels\$tunnelName' -Name 'Description' -Value '$tunnelDescription' -PropertyType String -Force -ea SilentlyContinue;
            New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels\$tunnelName' -Name 'Server' -Value '$vpnServer' -PropertyType String -Force -ea SilentlyContinue;
            New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels\$tunnelName' -Name 'promptusername' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;
"@


            New-Item -Path "$sourceFolderForti" -Name "FortiClient_SSL_VPN_regKeys.ps1" -Force -Value $script


            cls
            cd $AppSelectorSources
            ./IntuneWinAppUtil -c "$sourceFolderForti" -s "FortiClient_SSL_VPN_Config.ps1" -o "$outputDirectory" -q
            cls


#-----------------------------------------------------------------------------------------------------------------#
###################################################################################################################
#-----------------------------------------------------------------------------------------------------------------#
             
             ######Google Chrome######
             cd $AppSelectorSources
             ./IntuneWinAppUtil -c "$AppSelectorSources\GoogleChrome\GoogleChrome_Source" -s "Google Chrome.txt" -o "$outputDirectory" -q
             cls

            Write-Host "Configs have been safed under $outputDirectory" -foregroundcolor Green
            timeout 5
         }
     }
     pause
 }
 until ($selection -eq 'q')
