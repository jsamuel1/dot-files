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


