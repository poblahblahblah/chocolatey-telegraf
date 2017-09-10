﻿$ErrorActionPreference = 'Stop';

$unzip_folder    = $env:ProgramFiles
$install_folder  = "$unzip_folder\telegraf"
$configDirectory = Join-Path $install_folder 'telegraf.d'
$packageName     = 'telegraf'
$toolsDir        = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url             = 'https://dl.influxdata.com/telegraf/releases/telegraf-1.4.0_windows_i386.zip'
$url64           = 'https://dl.influxdata.com/telegraf/releases/telegraf-1.4.0_windows_amd64.zip'
$fileLocation    = Join-Path $install_folder 'telegraf.exe'

# Make sure the config directory exists
If(!(Test-Path -Path $configDirectory)){
  New-Item -Path $configDirectory -ItemType Directory
}

# If telegraf.exe exists, and the service is running, stop the service
If (Test-Path -Path $fileLocation){
  If (Get-Service -Name "telegraf" -ErrorAction SilentlyContinue) {
    Stop-Service -Name "telegraf"
    Start-Sleep -s 10
  }
}

# If telegraf.exe exists, and the service is enabled, uninstall the service
If (Test-Path -Path $fileLocation){
  If (Get-Service -Name "telegraf" -ErrorAction SilentlyContinue) {
    & $fileLocation --service uninstall
  }
}

# if the service is already defined, do not install the service
# otherwise install the service.
If (Get-Service -Name "telegraf" -ErrorAction SilentlyContinue) {
  $installArgs = ""
} Else {
  $installArgs = "--service install"
}

$packageArgs = @{
  packageName   = $packageName
  unzipLocation = $unzip_folder
  fileType      = 'EXE'
  url           = $url
  url64bit      = $url64
  file          = $fileLocation
  file64        = $fileLocation

  softwareName  = 'telegraf*'

  checksum       = '857447C06A7460B5C6014656B79D22DEA0A5F6D9C857113AA699946B3B7B8824'
  checksumType   = 'sha256'
  checksum64     = 'F23501F430C6BEB957266CC7E331FE3F45BC9BF0311176C6646C8E01B900D9DB'
  checksumType64 = 'sha256'

  silentArgs     = "--config-directory `"$configDirectory`" $installArgs"
  validExitCodes= @(0)
}

Install-ChocolateyZipPackage @packageArgs
Install-ChocolateyInstallPackage @packageArgs
