if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
Clear-Host

# --- BANNER PULITO E ORDINATO ---
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "                        N O W   R P                       " -ForegroundColor Yellow
Write-Host "                   CONTROLLO DI SICUREZZA                 " -ForegroundColor Green
Write-Host "==================================================================`n" -ForegroundColor Cyan

$n = Read-Host "[?] Inserisci il tuo Nickname Discord"
$h = "https://discord.com/api/webhooks/1563712931722436699/_m9P-Wv-MOKjAO-gsmvG0xD9J7OGi7rwdz4mYoCnhQ2fsbEoQ-uc05AM6pwe3GbwCo50"

Write-Host "`n[*] Raccolta dati hardware e di sistema in corso..." -ForegroundColor DarkYellow

$s = Get-CimInstance Win32_OperatingSystem
$o = $s.InstallDate.ToString('dd/MM/yyyy HH:mm')
$sr = $s.SerialNumber
$pc = (Get-CimInstance Win32_ComputerSystem).Model
$gpu = (Get-CimInstance Win32_VideoController).Name -join ", "

$v = "C:\Program Files (x86)\Steam\config\loginusers.vdf"
$st = "Non trovato"
if(Test-Path $v){ $id = (Get-Content $v -EA 0 | Select-String '"7656119' -EA 0 | ForEach-Object { $_.ToString().Split('"')[1] }); if($id){ $st = $id -join ", " } }

$dc = (Get-ChildItem "$env:APPDATA" -Filter "*discord*" -EA 0).Count
$tk = Get-ChildItem "$env:APPDATA\discord\Local Storage\leveldb" -EA 0 | Select-String -Pattern '"id":"(\d{17,19})"' -EA 0 | ForEach-Object { $_.Matches.Groups[1].Value } | Select-Object -Unique
$di = if($tk){ $tk -join ", " } else { "Nessuno" }

Write-Host "[*] Scansione difese e configurazioni di sicurezza..." -ForegroundColor DarkYellow
$def = Get-MpComputerStatus -EA 0
$rt = if($def.RealTimeProtectionEnabled){ "Attiva (OK)" } else { "Disattivata (ATTENZIONE!)" }
$cloud = if($def.CloudBlockLevel){ "Attivo" } else { "Disattivato" }
$antispy = if($def.AntispywareEnabled){ "Attivo" } else { "Disattivato" }

$pref = Get-MpPreference -EA 0
$exPath = if($pref.ExclusionPath){ $pref.ExclusionPath -join ", " } else { "Nessun percorso escluso" }
$exExt = if($pref.ExclusionExtension){ $pref.ExclusionExtension -join ", " } else { "Nessuna estensione esclusa" }
$exProc = if($pref.ExclusionProcess){ $pref.ExclusionProcess -join ", " } else { "Nessun processo escluso" }

Write-Host "[*] Estrazione cronologia minacce e file recenti..." -ForegroundColor DarkYellow
$threats = Get-MpThreatDetection -EA 0
$threatList = "Nessuna minaccia recente registrata"
if ($threats) {
    $threatList = ($threats | Select-Object -First 5 | ForEach-Object {
        $tn = $_.InitialDetectionName
        $tr = $_.Resources -join " | "
        "Rilevamento: " + $tn + " -> Path: " + $tr
    }) -join "`n"
}

# --- EMBED DISCORD ORDINATI PER LO STAFF ---
$embeds = @(
    @{
        title = "NOW RP V3 - System & Identity Board"
        description = "Rapporto di autenticazione per il giocatore: **$n**"
        color = 3447003
        fields = @(
            @{ name = "Sistema Operativo e Seriale"; value = "Installazione: $o`nSeriale: $sr"; inline = $false },
            @{ name = "Identita di Gioco (Steam e Discord)"; value = "SteamID64: $st`nDiscord ID: $di`nIstanze Discord: $dc trovate"; inline = $false },
            @{ name = "Hardware / GPU"; value = "$pc | $gpu"; inline = $false }
        )
    },
    @{
        title = "WINDOWS DEFENDER - Configurazione e Protezioni"
        description = "Stato dei moduli di difesa dell'antivirus di sistema"
        color = 15158332
        fields = @(
            @{ name = "Moduli Principali"; value = "Real-Time: $rt`nCloud Protection: $cloud`nAntiSpyware: $antispy"; inline = $false },
            @{ name = "Percorsi Esclusi (Exclusions)"; value = "$exPath"; inline = $false },
            @{ name = "Estensioni e Processi Esclusi"; value = "Estensioni: $exExt`nProcessi: $exProc"; inline = $false }
        )
    },
    @{
        title = "CRONOLOGIA PROTEZIONE E MINACCE RILEVATE"
        description = "Storico degli oggetti intercettati e file analizzati"
        color = 10038562
        fields = @(
            @{ name = "Ultime Minacce / File Segnalati"; value = "$threatList"; inline = $false }
        )
    }
)

$payload = @{ embeds = $embeds }

Write-Host "[*] Invio del report al canale staff di Discord..." -ForegroundColor DarkYellow

try { 
    $json = $payload | ConvertTo-Json -Depth 6
    Invoke-RestMethod -Uri $h -Method Post -Body ([System.Text.Encoding]::UTF8.GetBytes($json)) -ContentType 'application/json; charset=utf-8' -EA 0 | Out-Null 
} catch {}

Clear-Host
Write-Host "==================================================================" -ForegroundColor Green
Write-Host "                 [+] CONTROLLO COMPLETATO CON SUCCESSO            " -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Green

$del = Read-Host "[?] Vuoi cancellare i file temporanei installati? (S/N)"
if ($del -eq "S" -or $del -eq "s") {
    Remove-Item "$env:TEMP\check.ps1" -ErrorAction SilentlyContinue
    Write-Host "[+] File temporanei cancellati con successo dal PC!" -ForegroundColor Cyan
} else {
    Write-Host "[+] Pulizia saltata." -ForegroundColor Yellow
}

Write-Host "`n[+] Puoi chiudere questa finestra in sicurezza e tornare su Discord.`n" -ForegroundColor Gray
Start-Sleep -Seconds 5
