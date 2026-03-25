# Naio's Laptop — Ollama Setup for Hive Cluster (Node 2)
# Run this in PowerShell as Administrator
# This makes Ollama accessible to the family Tailscale network

Write-Host "=== Setting up Ollama for Hive Cluster ===" -ForegroundColor Cyan

# 1. Set Ollama to listen on all interfaces
[System.Environment]::SetEnvironmentVariable("OLLAMA_HOST", "0.0.0.0", "User")
Write-Host "Set OLLAMA_HOST=0.0.0.0" -ForegroundColor Green

# 2. Open firewall for Tailscale (port 11434)
New-NetFirewallRule -Name "Ollama-Tailscale" -DisplayName "Ollama Tailscale" -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 11434 -ErrorAction SilentlyContinue
Write-Host "Firewall rule added for port 11434" -ForegroundColor Green

# 3. Open firewall for SSH (port 22)
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0 -ErrorAction SilentlyContinue
Start-Service sshd -ErrorAction SilentlyContinue
Set-Service -Name sshd -StartupType Automatic -ErrorAction SilentlyContinue
New-NetFirewallRule -Name "OpenSSH-Server" -DisplayName "OpenSSH Server" -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 -ErrorAction SilentlyContinue
Write-Host "SSH server enabled" -ForegroundColor Green

# 4. Restart Ollama
Stop-Process -Name "ollama*" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3
Start-Process "ollama" -ArgumentList "serve" -WindowStyle Hidden
Start-Sleep -Seconds 5

# 5. Verify
$listening = netstat -an | Select-String "11434.*LISTENING"
if ($listening) {
    Write-Host "Ollama listening on 0.0.0.0:11434" -ForegroundColor Green
} else {
    Write-Host "WARNING: Ollama not listening yet. Try restarting the Ollama app from Start menu." -ForegroundColor Yellow
}

# 6. Show models
& ollama list

Write-Host ""
Write-Host "=== DONE ===" -ForegroundColor Cyan
Write-Host "Tailscale IP: Run 'tailscale ip' to confirm"
Write-Host "Dad's machine can now reach your Ollama at this IP on port 11434"
