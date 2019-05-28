Import-Module Get-ChildItemColor
Set-Alias l Get-ChildItemColor -Option AllScope
Set-Alias ls Get-ChildItemColorFormatWide -Option AllScope

function cuserprofile { Set-Location ~ }
Set-Alias ~ cuserprofile -Option AllScope

Import-Module -Name posh-git

Import-Module -Name oh-my-posh
Set-Theme agnoster
