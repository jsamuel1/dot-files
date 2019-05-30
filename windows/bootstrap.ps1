# Ensure running as Admin first
#
If ( -NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    #Relaunch as elevated
    if ($PSVersionTable.PSVersion -lt "6.0") {
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    }
    else {
        Start-Process pwsh.exe "-NoProfile -File `"$PSCommandPath`"" -Verb RunAs
    }
    exit
}

Set-Location $PSScriptRoot

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force

if (-not (Test-Path $PROFILE)) {
    New-Item -Path $PROFILE -ItemType SymbolicLink -Value .\profile.ps1
}

# install chocolatey
if (-not (Test-Path -Path $env:ChocolateyInstall)) {
    iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex
}

if (-not (Test-Path "fonts")) {
    git clone https://github.com/powerline/fonts.git
    . fonts\install.ps1
}

if ($PSVersionTable.PSVersion -lt "6.0") {
    Install-PackageProvider NuGet -MinimumVersion '2.8.5.201'
}
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name 'posh-git'
Install-Module -Name 'oh-my-posh'
Install-Module -Name 'Get-ChildItemColor'

# install scoop
if (-not (Test-Path "~\scoop\apps\scoop\current\bin\scoop.ps1"))
{
iex(new-object net.webclient).downloadstring('https://get.scoop.sh')
}
else
{
   scoop update
}

scoop bucket add anurse https://github.com/anurse/scoop-bucket
scoop bucket add extras
scoop install 7zip
scoop install aria2
scoop install beyondcompare
scoop install chrome
scoop install coreutils
scoop install curl
scoop install docker-nightly docker-compose minikube kubectl
scoop install findutils
scoop install git
scoop install gitversion
scoop install go
scoop install grep
scoop install grep
scoop install hub
scoop install less
scoop install neovim
scoop install nodejs
scoop install pwsh
scoop install python
scoop install sed
scoop install sublime-text
scoop install sudo
scoop install sysinternals
scoop install unzip
scoop install vscode
scoop install win32-openssh
scoop install win32yank
scoop install yarn
scoop install zip

[environment]::setenvironmentvariable('GIT_SSH', (resolve-path (scoop which ssh)), 'USER')

sudo Enable-WindowsOptionalFeature -Online -FeatureName containers -All -NoRestart
sudo Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart

if (-NOT (Test-Path -Path "~\AppData\Local\nvim")) { mkdir -Path "~\AppData\Local\nvim" }
if (-NOT (Test-Path -Path "~\AppData\Local\nvim\autoload")) { mkdir -Path "~\AppData\Local\nvim\autoload" }
if (-NOT (Test-Path -Path "~\AppData\Local\nvim\autoload\plug.vim")) {
    $uri = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    (New-Object Net.WebClient).DownloadFIle($uri, $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath("~\AppData\Local\nvim\autoload\plug.vim"))
}
if (-not (Test-Path "~\AppData\Local\nvim\init.vim")) {
	New-Item -Path "~\AppData\Local\nvim\init.vim" -ItemType SymbolicLink -Value ..\vimrc
}

# finally, ensure Windows Subsystem for linux installed
sudo cinst wsl-ubuntu-1804 -y

