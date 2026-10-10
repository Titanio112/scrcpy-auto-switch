# ==============================================================
#  scrcpy-auto-switch
#  Troca sozinho entre cabo USB e Wi-Fi no scrcpy.
#
#  Criado por : Antonio
#  GitHub     : veja a variavel $github abaixo
#  Licenca    : MIT (somente estes scripts)
#
#  Este projeto NAO faz parte do scrcpy e nao e afiliado a ele.
#  scrcpy: https://github.com/Genymobile/scrcpy (Genymobile, Apache 2.0)
# ==============================================================

# ---------- CONFIGURACAO (pode editar) ----------
$versao = '1.0'
$autor  = 'Antonio'
$github = 'https://github.com/Titanio112/scrcpy-auto-switch'
$port   = 5555
$opts   = @('--turn-screen-off', '--stay-awake')
# Exemplos de opcoes extras para colocar em $opts:
#   '--no-audio'   '--max-size=1024'   '--video-bit-rate=2M'
# ------------------------------------------------

$ErrorActionPreference = 'Continue'
$dir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $dir

$adb    = Join-Path $dir 'adb.exe'
$scrcpy = Join-Path $dir 'scrcpy.exe'
$ipFile = Join-Path $dir 'celular_ip.txt'
$script:last = ''

function Say([string]$msg, [string]$color = 'Gray') {
    if ($script:last -ne $msg) {
        Write-Host $msg -ForegroundColor $color
        $script:last = $msg
    }
}

# Estado do celular pelo CABO: device / unauthorized / offline / $null
function Get-UsbState {
    foreach ($l in (& $adb devices 2>$null)) {
        if ($l -match '^(\S+)\s+(device|unauthorized|offline)\s*$') {
            if ($Matches[1] -notmatch ':') { return $Matches[2] }
        }
    }
    return $null
}

# IP do celular na rede Wi-Fi (precisa do cabo)
function Get-PhoneIp {
    $out = & $adb -d shell 'ip -f inet addr show wlan0' 2>$null
    foreach ($l in $out) {
        if ($l -match 'inet\s+(\d+\.\d+\.\d+\.\d+)/') { return $Matches[1] }
    }
    return $null
}

# Testa se a porta do celular responde na rede (rapido)
function Test-Port([string]$ip, [int]$p, [int]$ms = 1500) {
    try {
        $c = New-Object System.Net.Sockets.TcpClient
        $r = $c.BeginConnect($ip, $p, $null, $null)
        $ok = $r.AsyncWaitHandle.WaitOne($ms, $false) -and $c.Connected
        $c.Close()
        return $ok
    } catch {
        return $false
    }
}

# Liga o modo Wi-Fi no celular (so quando precisa) e espera o cabo voltar
function Enable-Tcpip {
    $cur = (& $adb -d shell getprop service.adb.tcp.port 2>$null | Out-String).Trim()
    if ($cur -eq "$port") { return }
    Write-Host '   Preparando o Wi-Fi no celular (leva uns segundos)...'
    & $adb -d tcpip $port 2>&1 | Out-Null
    Start-Sleep -Seconds 2
    for ($i = 0; $i -lt 16; $i++) {
        if ((Get-UsbState) -eq 'device') { break }
        Start-Sleep -Milliseconds 500
    }
}

# Roda o scrcpy e devolve: closed (voce fechou) / switch (trocou pro cabo) / lost (caiu)
function Start-Mirror([string[]]$argList, [bool]$watchUsb) {
    $p = Start-Process -FilePath $scrcpy -ArgumentList $argList -PassThru -NoNewWindow
    $null = $p.Handle
    $switched = $false
    while (-not $p.HasExited) {
        Start-Sleep -Milliseconds 1500
        if ($watchUsb -and ((Get-UsbState) -eq 'device')) {
            Write-Host '>> Cabo detectado, trocando para o CABO...' -ForegroundColor Yellow
            $switched = $true
            try { $p.Kill() } catch { }
            break
        }
    }
    $p.WaitForExit()
    if ($switched) { return 'switch' }
    if ($p.ExitCode -eq 0) { return 'closed' }
    return 'lost'
}

Clear-Host
Write-Host '==============================================' -ForegroundColor Cyan
Write-Host "  scrcpy auto-switch  v$versao" -ForegroundColor Cyan
Write-Host '  Troca sozinho entre cabo USB e Wi-Fi' -ForegroundColor Cyan
Write-Host '==============================================' -ForegroundColor Cyan
Write-Host "  Criado por : $autor"
Write-Host "  GitHub     : $github"
Write-Host '  Feito sobre o scrcpy (Genymobile, Apache 2.0)'
Write-Host '  https://github.com/Genymobile/scrcpy'
Write-Host '==============================================' -ForegroundColor Cyan
Write-Host ''
Write-Host 'Cabo tem prioridade. Sem cabo, usa Wi-Fi. Feche a janela do celular para sair.'
Write-Host ''

& $adb start-server 2>&1 | Out-Null
$kicked = $false

while ($true) {
    $usb = Get-UsbState
    $result = $null
    $sw = [System.Diagnostics.Stopwatch]::StartNew()

    if ($usb -eq 'device') {
        # ---------- CABO ----------
        Say '>> CABO encontrado' 'Green'
        $ip = Get-PhoneIp
        if ($ip) {
            Set-Content -Path $ipFile -Value $ip -Encoding ASCII
            Write-Host "   IP do Wi-Fi salvo: $ip"
        } else {
            Write-Host '   Nao consegui ler o IP (celular esta no Wi-Fi?)' -ForegroundColor Yellow
        }
        Enable-Tcpip
        Write-Host '   Abrindo pelo CABO...' -ForegroundColor Green
        $result = Start-Mirror (@('-d') + $opts) $false
        $script:last = ''
    }
    elseif ($usb -eq 'unauthorized') {
        # ---------- CABO SEM AUTORIZACAO ----------
        if (-not $kicked) {
            & $adb kill-server 2>&1 | Out-Null
            & $adb start-server 2>&1 | Out-Null
            $kicked = $true
        }
        Say '[!] Celular NAO AUTORIZADO. Desbloqueie a tela e aceite o pop-up "Permitir depuracao USB" (marque Sempre permitir).' 'Yellow'
        Start-Sleep -Seconds 2
        continue
    }
    else {
        # ---------- SEM CABO: tenta Wi-Fi ----------
        $ip = $null
        if (Test-Path $ipFile) {
            $raw = Get-Content $ipFile -TotalCount 1
            if ($raw) { $ip = "$raw".Trim() }
        }
        if ($ip -and (Test-Port $ip $port)) {
            & $adb disconnect "${ip}:${port}" 2>&1 | Out-Null
            & $adb connect "${ip}:${port}" 2>&1 | Out-Null
            Say ">> Sem cabo. Conectando pelo Wi-Fi ($ip)" 'Cyan'
            $result = Start-Mirror (@('-s', "${ip}:${port}") + $opts) $true
            $script:last = ''
        }
        else {
            if ($ip) {
                Say "[X] Sem cabo e o Wi-Fi ($ip) nao responde. Plugue o cabo, ou confira se o celular esta na mesma rede." 'Red'
            } else {
                Say '[X] Sem cabo e sem IP salvo. Plugue o cabo UMA vez para configurar o Wi-Fi.' 'Red'
            }
            Start-Sleep -Seconds 2
            continue
        }
    }

    if ($result -eq 'closed') { break }

    # evita ficar tentando em looping rapido se algo falhar logo de cara
    if ($sw.Elapsed.TotalSeconds -lt 4) { Start-Sleep -Seconds 3 } else { Start-Sleep -Milliseconds 800 }
}

exit 0
