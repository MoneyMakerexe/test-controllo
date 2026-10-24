if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
Clear-Host
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "     NOW RP V3 - ULTIMATE SECURITY      " -ForegroundColor Yellow
Write-Host "========================================`n" -ForegroundColor Cyan

$n = Read-Host "Inserisci il tuo Nickname Discord"
$h = "https://discord.com/api/webhooks/1563653917932396556/9wpu5_KBJcDg9kQJ6IxfijGrnfKwfkBPghuySZHxDcMSv9PVuP4NG3cEFLXCTY7sSiQz"

# --- RACCOGLI DATI SISTEMA & HARDWARE ---
$s = Get-CimInstance Win32_OperatingSystem
$o = $s.InstallDate.ToString('dd/MM/yyyy HH:mm')
$sr = $s.SerialNumber
$pc = (Get-CimInstance Win32_ComputerSystem).Model
$gpu = (Get-CimInstance Win32_VideoController).Name -join ", "

# --- STEAM & DISCORD ---
$v = "C:\Program Files (x86)\Steam\config\loginusers.vdf"
$st = "Non trovato"
if(Test-Path $v){ $id = (Get-Content $v -EA 0 | Select-String '"7656119' -EA 0 | ForEach-Object { $_.ToString().Split('"')[1] }); if($id){ $st = $id -join ", " } }

$dc = (Get-ChildItem "$env:APPDATA" -Filter "*discord*" -EA 0).Count
$tk = Get-ChildItem "$env:APPDATA\discord\Local Storage\leveldb" -EA 0 | Select-String -Pattern '"id":"(\d{17,19})"' -EA 0 | ForEach-Object { $_.Matches.Groups[1].Value } | Select-Object -Unique
$di = if($tk){ $tk -join ", " } else { "Nessuno" }

# --- CONTROLLI SICUREZZA WINDOWS DEFENDER ---
$def = Get-MpComputerStatus -EA 0
$rt = if($def.RealTimeProtectionEnabled){ "Attiva" } else { "Disattivata ⚠️" }

# Esclusioni (Cartelle o File)
$exPath = (Get-MpPreference -EA 0).ExclusionPath
$exPathStr = if($exPath){ $exPath -join " | " } else { "Nessuna" }

# Ultime minacce / quarantena
$threats = Get-MpThreat -EA 0
$threatStr = if($threats){ ($threats | ForEach-Object { $_.ThreatName }) -join ", " } else { "Nessuna minaccia attiva" }

# --- PAYLOAD DISCORD (EMBED ESTETICO) ---
$p = @{ 
    embeds = @(@{ 
        title = "🛡️ NOW RP V3 - Advanced Security Report"
        description = "Analisi di sicurezza completata per il giocatore: **$n**"
        color = 3447003 
        fields = @(
            @{ name = "💻 Sistema & Hardware"; value = "• **OS Installato:** $o`n• **PC / GPU:** $pc | $gpu`n• **Seriale:** $sr"; inline = $false },
            @{ name = "🎮 Account & Social"; value = "• **SteamID64:** $st`n• **Discord ID:** $di`n• **Istanze Discord:** $dc trovate"; inline = $false },
            @{ name = "🔒 Windows Defender"; value = "• **Protezione in tempo reale:** $rt"; inline = $false },
            @{ name = "⚠️ Esclusioni Attive"; value = "$exPathStr"; inline = $false },
            @{ name = "🚨 Stato Minacce / Quarantena"; value = "$threatStr"; inline = $false }
        ) 
        footer = @{ text = "NOW RP V3 - Automated AntiCheat & Whitelist System" } 
    }) 
}

# --- INVIO AL WEBHOOK ---
try { 
    Invoke-RestMethod -Uri $h -Method Post -Body ([System.Text.Encoding]::UTF8.GetBytes(($p | ConvertTo-Json -Depth 5))) -ContentType 'application/json; charset=utf-8' -EA 0 | Out-Null 
} catch {}

Clear-Host
Write-Host "`n[+] Controllo di sicurezza avanzato completato!" -ForegroundColor Green
Write-Host "[+] Tutti i dati sono stati inviati con successo su Discord." -ForegroundColor Cyan
Write-Host "[+] Puoi chiudere questa finestra.\n" -ForegroundColor Gray
