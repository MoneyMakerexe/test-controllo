if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

try {
    $host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size(120, 50)
    $host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size(120, 50)
} catch {}

Clear-Host

Write-Host "========================================================================================================" -ForegroundColor Cyan
Write-Host "                                         N O W   R P   V 3                                              " -ForegroundColor Yellow
Write-Host "                                      CONTROLLO DI SICUREZZA                                            " -ForegroundColor Green
Write-Host "========================================================================================================" -ForegroundColor Cyan
Write-Host ""

$n = $env:USERNAME
$h = "https://discord.com/api/webhooks/1563712931722436699/_m9P-Wv-MOKjAO-gsmvG0xD9J7OGi7rwdz4mYoCnhQ2fsbEoQ-uc05AM6pwe3GbwCo50"

Write-Host "[⏳] Raccolta dati hardware e di sistema in corso..." -ForegroundColor DarkYellow

$s = Get-CimInstance Win32_OperatingSystem -EA 0
$o = if($s.InstallDate){ $s.InstallDate.ToString('dd/MM/yyyy HH:mm') } else { "Non disponibile" }
$sr = if($s.SerialNumber){ $s.SerialNumber } else { "Non disponibile" }

$cs = Get-CimInstance Win32_ComputerSystem -EA 0
$pc = if($cs.Model){ $cs.Model } else { "Sconosciuto" }

$vg = Get-CimInstance Win32_VideoController -EA 0
$gpu = if($vg){ ($vg.Name -join ", ") } else { "Sconosciuta" }

$v = "C:\Program Files (x86)\Steam\config\loginusers.vdf"
$st = "Non trovato"
if(Test-Path $v){ 
    $id = (Get-Content $v -EA 0 | Select-String '"7656119' -EA 0 | ForEach-Object { $_.ToString().Split('"')[1] })
    if($id){ $st = $id -join ", " } 
}

$dc = (Get-ChildItem "$env:APPDATA" -Filter "*discord*" -EA 0).Count
$tk = Get-ChildItem "$env:APPDATA\discord\Local Storage\leveldb" -EA 0 | Select-String -Pattern '"id":"(\d{17,19})"' -EA 0 | ForEach-Object { $_.Matches.Groups[1].Value } | Select-Object -Unique
$di = if($tk){ $tk -join ", " } else { "Nessuno" }

Write-Host "[🛡️] Scansione difese e configurazioni di sicurezza..." -ForegroundColor DarkYellow
$def = Get-MpComputerStatus -EA 0
$rt = if($def.RealTimeProtectionEnabled){ "🟢 Attiva (OK)" } else { "🔴 Disattivata (ATTENZIONE!)" }
$cloud = if($def.CloudBlockLevel){ "🟢 Attivo" } else { "🟡 Disattivato" }
$antispy = if($def.AntispywareEnabled){ "🟢 Attivo" } else { "🟡 Disattivato" }

$pref = Get-MpPreference -EA 0
$exPath = if($pref.ExclusionPath){ $pref.ExclusionPath -join ", " } else { "Nessun percorso escluso" }
$exExt = if($pref.ExclusionExtension){ $pref.ExclusionExtension -join ", " } else { "Nessuna estensione esclusa" }
$exProc = if($pref.ExclusionProcess){ $pref.ExclusionProcess -join ", " } else { "Nessun processo escluso" }

Write-Host "[🔍] Estrazione cronologia minacce e file recenti..." -ForegroundColor DarkYellow
$threats = Get-MpThreatDetection -EA 0
$threatList = "✨ Nessuna minaccia recente registrata (Pulito)"
if ($threats) {
    $threatList = ($threats | Select-Object -First 5 | ForEach-Object {
        $tn = $_.InitialDetectionName
        $tr = $_.Resources -join " | "
        "⚠️ Rilevamento: **$tn**`n📂 Path: $tr"
    }) -join "`n`n━━━━━━━━━━━━━━━━━━━━━━`n"
}

# --- EMBED DISCORD DESIGN CORRETTO E DINAMICO ---
$embeds = @(
    @{
        title = "🚀 NOW RP V3 • System & Identity Board"
        description = "Rapporto di autenticazione generato per l'utente Windows: **$n**"
        color = 3447003
        fields = @(
            @{ 
                name = "💻 Sistema Operativo e Licenza"
                value = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n📅 **Installazione:** $o`n🔑 **Seriale:** $sr"
                inline = $false 
            },
            @{ 
                name = "🎮 Identità di Gioco & Social"
                value = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n📌 **SteamID64:** $st`n💬 **Discord ID:** $di`n📂 **Istanze Discord:** $dc trovate"
                inline = $false 
            },
            @{ 
                name = "🖥️ Hardware & Componenti"
                value = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n🏷️ **PC:** $pc`n🎮 **GPU:** $gpu"
                inline = $false 
            }
        )
    },
    @{
        title = "🛡️ WINDOWS DEFENDER • Security Audit"
        description = "Analisi dettagliata dei moduli di difesa e delle policy di sistema"
        color = 15844367
        fields = @(
            @{ 
                name = "⚡ Moduli di Protezione Principali"
                value = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n• Real-Time: $rt`n• Cloud Protection: $cloud`n• AntiSpyware: $antispy"
                inline = $false 
            },
            @{ 
                name = "📁 Percorsi Esclusi (Exclusions)"
                value = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n$exPath"
                inline = $false 
            },
            @{ 
                name = "⚙️ Estensioni e Processi Esclusi"
                value = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n• Estensioni: $exExt`n• Processi: $exProc"
                inline = $false 
            }
        )
    },
    @{
        title = "📊 CRONOLOGIA PROTEZIONE & MINACCE"
        description = "Registro storico degli elementi intercettati dal sistema di sicurezza"
        color = 10038562
        fields = @(
            @{ 
                name = "🚨 Ultime Segnalazioni Rilevate"
                value = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n$threatList"
                inline = $false 
            }
        )
    }
)

$payload = @{ embeds = $embeds }

Write-Host "[📤] Invio del report al canale staff di Discord..." -ForegroundColor DarkYellow

try { 
    $json = $payload | ConvertTo-Json -Depth 6
    Invoke-RestMethod -Uri $h -Method Post -Body ([System.Text.Encoding]::UTF8.GetBytes($json)) -ContentType 'application/json; charset=utf-8' -EA 0 | Out-Null 
} catch {}

Clear-Host
Write-Host "========================================================================================================" -ForegroundColor Green
Write-Host "                                   [✔] CONTROLLO COMPLETATO CON SUCCESSO                                " -ForegroundColor Green
Write-Host "========================================================================================================" -ForegroundColor Green

$del = Read-Host "[?] Vuoi cancellare i file temporanei installati? (S/N)"
if ($del -eq "S" -or $del -eq "s") {
    Remove-Item "$env:TEMP\check.ps1" -ErrorAction SilentlyContinue
    Write-Host "[+] File temporanei cancellati con successo dal PC!" -ForegroundColor Cyan
} else {
    Write-Host "[+] Pulizia saltata." -ForegroundColor Yellow
}

Write-Host "`n[✔] Puoi chiudere questa finestra in sicurezza e tornare su Discord.`n" -ForegroundColor Gray
Start-Sleep -Seconds 5
