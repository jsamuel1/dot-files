Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force

# install chocolatey
iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex

cinst git.install -y

cinst cmder -y

git clone https://github.com/powerline/fonts.git
# . fonts\install.ps1

Install-PackageProvider NuGet -MinimumVersion '2.8.5.201' -Force
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name 'posh-git'
Install-Module -Name 'oh-my-posh'
Install-Module -Name 'Get-ChildItemColor'

scoop bucket add anurse https://github.com/anurse/scoop-bucket
scoop bucket add extras
scoop install 7zip
scoop install aria2
scoop install beyondcompare
scoop install chrome
scoop install docker-nightly docker-compose minikube kubectl
scoop install go
scoop install grep
scoop install less
scoop install pwsh
scoop install sublime-text
scoop install sudo
scoop install sysinternals
scoop install unzip
scoop install vscode
scoop install win32yank
scoop install zip

sudo Enable-WindowsOptionalFeature -Online -FeatureName containers -All -NoRestart
sudo Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart

