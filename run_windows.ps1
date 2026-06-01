$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
if (-not (Test-Path $regPath)) { New-Item -Path $regPath -Force | Out-Null }
Set-ItemProperty -Path $regPath -Name AllowDevelopmentWithoutDevLicense -Value 1 -Type DWord
Set-ItemProperty -Path $regPath -Name AllowAllTrustedApps -Value 1 -Type DWord
Write-Host "Developer Mode enabled!" -ForegroundColor Green
Set-Location "i:\PERFECT ONE APP HUNGER POINT\hunger_point_full"
Write-Host "Building Flutter Windows debug app..." -ForegroundColor Cyan
flutter run -d windows --debug
