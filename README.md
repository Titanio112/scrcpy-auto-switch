# Wireflex-Scrcpy

🇧🇷 Português | 🇺🇸 [English](#english)

Espelhe a tela do seu Android no Windows e deixe o **cabo USB e o Wi-Fi trocarem sozinhos**.

- Tirou o cabo? Continua pelo **Wi-Fi**.
- Plugou de novo? Volta pro **cabo**.
- Sem clicar em nada, sem digitar IP, sem digitar comando.

> Projeto feito por diversão e compartilhado com a comunidade, em cima do [scrcpy](https://github.com/Genymobile/scrcpy).
> O scrcpy **não está incluído** aqui: você baixa ele separado (passo a passo abaixo).

---

## O que ele faz

| Situação | O que acontece |
|---|---|
| Celular no cabo | Abre pelo **cabo** (mais fluido) |
| Tirou o cabo | Reabre sozinho pelo **Wi-Fi** em poucos segundos |
| Plugou o cabo de novo | Volta pro **cabo** |
| Sem cabo e sem Wi-Fi | Avisa na tela e fica esperando |
| Fechou a janela do celular | Encerra tudo |

Extras:

- Descobre e salva o IP do celular sozinho
- Liga o modo Wi-Fi do celular sozinho
- Apaga a tela do celular enquanto espelha e mantém ele acordado (dá pra desligar)

---

## Antes de baixar: o que você precisa

- **Windows 10 ou 11** (usa o PowerShell, que já vem no Windows)
- Celular **Android 5.0 ou superior** (requisito do scrcpy) com **Depuração USB** ligada
- **Um cabo USB**, pelo menos uma vez, para configurar o Wi-Fi
- PC e celular na **mesma rede Wi-Fi** (só para o modo sem fio)
- O **scrcpy para Windows** (grátis): <https://github.com/Genymobile/scrcpy/releases>

---

## Instalação

1. Baixe o **scrcpy para Windows** (`scrcpy-win64-vX.X.zip`) na página de releases e extraia
2. Baixe este projeto: na aba [**Releases**](https://github.com/Titanio112/scrcpy-auto-switch/releases) pegue o zip da versão mais recente (ou botão verde **Code → Download ZIP**) e extraia
3. Copie estes 2 arquivos para **dentro da pasta do scrcpy** (onde está o `scrcpy.exe`):
    - `scrcpy-auto.bat`
    - `scrcpy-auto.ps1`
4. *(Opcional)* Botão direito no `scrcpy-auto.bat` → **Enviar para → Área de trabalho (criar atalho)**

Os dois arquivos precisam ficar **juntos**, na mesma pasta do `scrcpy.exe` e do `adb.exe`.

---

## Configurando o celular (só uma vez)

1. **Configurações → Sobre o telefone** e toque **7 vezes** em *Número da versão* (em alguns Samsung fica em *Informações do software*)
2. **Opções do desenvolvedor → Depuração USB**: ligar
3. Plugue o cabo e aceite o pop-up **"Permitir depuração USB"** (marque **Sempre permitir**)

---

## Como usar

**Primeira vez**

1. Com o **cabo plugado**, dê dois cliques em `scrcpy-auto.bat`
2. Espere uns segundos: ele salva o IP e prepara o Wi-Fi
3. A tela do celular aparece. Agora **tire o cabo** e veja ele trocar pro Wi-Fi

**No dia a dia**

- Dois cliques no `scrcpy-auto.bat`. Com cabo, abre pelo cabo. Sem cabo, vai direto pro Wi-Fi.

**Quando precisa plugar o cabo de novo**

- O celular foi **reiniciado** (o modo Wi-Fi é desligado no reboot)
- O **IP do celular mudou** (outra rede, ou o roteador deu outro IP)
- Basta plugar o cabo com o script aberto: ele atualiza tudo sozinho

---

## Personalizando

Abra o `scrcpy-auto.ps1` no Bloco de Notas. No começo do arquivo tem a seção **CONFIGURAÇÃO**:

```powershell
$opts = @('--turn-screen-off', '--stay-awake')
```

Exemplos:

```powershell
# Sem apagar a tela do celular
$opts = @('--stay-awake')

# Mais leve (bom pra Wi-Fi fraco), sem áudio
$opts = @('--turn-screen-off', '--no-audio', '--max-size=1024', '--video-bit-rate=2M')
```

Veja todas as opções na [documentação do scrcpy](https://github.com/Genymobile/scrcpy#readme).

---

## Problemas comuns

**"Celular NÃO AUTORIZADO"**
- Desbloqueie a tela e aceite o pop-up de depuração USB
- Se não aparecer: *Opções do desenvolvedor → Revogar autorizações de depuração USB*, tire e plugue o cabo de novo
- Puxe a barra de notificações e deixe o USB em **Transferência de arquivos**

**"Sem cabo e o Wi-Fi não responde"**
- PC e celular estão na mesma rede?
- O celular reiniciou? Plugue o cabo uma vez
- O IP mudou? Plugue o cabo uma vez

**O Windows avisou sobre o arquivo (SmartScreen)**
- Clique em *Mais informações → Executar assim mesmo*
- São arquivos de texto simples: abra no Bloco de Notas e confira o que fazem

**Erro de "execução de scripts desabilitada"**
- O `.bat` já abre o PowerShell com `-ExecutionPolicy Bypass` só para esse script, sem mudar nenhuma configuração do seu Windows

**A troca demora uns segundos**
- É normal: a janela fecha e reabre (2 a 4 segundos)

---

## Como funciona por baixo

- Verifica o cabo com `adb devices`
- Lê o IP do celular com `ip addr show wlan0` e salva em `celular_ip.txt`
- Liga o ADB por Wi-Fi com `adb tcpip 5555` (só quando precisa)
- Abre o `scrcpy -d` (cabo) ou `scrcpy -s IP:5555` (Wi-Fi)
- Quando o scrcpy fecha por desconexão, tenta o outro caminho. Quando você fecha a janela, encerra
- Durante o Wi-Fi, fica de olho no cabo: se plugar, troca de volta

---

## Segurança

- O modo Wi-Fi deixa o celular aceitando conexão ADB na porta 5555 **até reiniciar**
- PCs novos precisam ser autorizados no celular, mas mesmo assim **evite usar em Wi-Fi público ou desconhecido**
- O arquivo `celular_ip.txt` é gerado na sua pasta e já está no `.gitignore`

---

## Créditos

- **Criado por** [Titanio112](https://github.com/Titanio112)
- **[scrcpy](https://github.com/Genymobile/scrcpy)** por [Genymobile](https://github.com/Genymobile) (Romain Vimont e colaboradores), licença Apache 2.0. Este projeto não é afiliado ao scrcpy e não distribui os arquivos dele
- Roteiro escrito com ajuda do Claude (Anthropic)

## Licença

[MIT](LICENSE): vale somente para os scripts deste repositório. O scrcpy tem a licença própria dele.

---

<a id="english"></a>

## English

**scrcpy-auto-switch** is a small Windows launcher (`.bat` + PowerShell) that wraps [scrcpy](https://github.com/Genymobile/scrcpy) and **switches automatically between USB and Wi-Fi**.

- Unplug the cable: it reconnects over **Wi-Fi**.
- Plug it back in: it returns to **USB**.
- No typing IPs, no commands.

> A hobby project shared with the community. scrcpy is **not** included and this project is **not affiliated** with it.

### What it does

| Situation | What happens |
|---|---|
| Phone on USB | Opens over **USB** (smoother) |
| Cable unplugged | Reopens over **Wi-Fi** within a few seconds |
| Cable plugged back in | Returns to **USB** |
| No cable and no Wi-Fi | Shows what to check and keeps waiting |
| You close the phone window | Everything exits |

It also finds and saves your phone's Wi-Fi IP automatically, and turns on ADB over Wi-Fi by itself.

### Requirements

- Windows 10 or 11 (uses the built-in PowerShell)
- Android 5.0+ with **USB debugging** enabled
- A USB cable, at least once, to set up Wi-Fi
- PC and phone on the **same Wi-Fi network** (for wireless mode)
- [scrcpy for Windows](https://github.com/Genymobile/scrcpy/releases) (free)

### Install

1. Download and extract scrcpy for Windows from its [releases page](https://github.com/Genymobile/scrcpy/releases)
2. Download this project from the [Releases](https://github.com/Titanio112/scrcpy-auto-switch/releases) tab (or **Code → Download ZIP**)
3. Copy `scrcpy-auto.bat` and `scrcpy-auto.ps1` **into the scrcpy folder** (next to `scrcpy.exe` and `adb.exe`)
4. Phone: tap *Build number* 7 times, then enable **USB debugging** in Developer options
5. Plug the phone in and accept the **"Allow USB debugging"** prompt (tick *Always allow*)
6. Double-click `scrcpy-auto.bat`

### Usage

- **First run:** plug the cable in, run the script, wait a few seconds (it saves the IP and enables Wi-Fi). Then unplug the cable and watch it switch to Wi-Fi.
- **Daily use:** double-click `scrcpy-auto.bat`. With a cable it opens over USB, without one it goes straight to Wi-Fi.
- **Plug the cable in again** if the phone was rebooted (wireless ADB is turned off on reboot) or if the phone's IP changed. The script updates everything by itself.

### Customizing

Open `scrcpy-auto.ps1` in Notepad and edit the options at the top:

```powershell
# Default
$opts = @('--turn-screen-off', '--stay-awake')

# Keep the phone screen on
$opts = @('--stay-awake')

# Lighter for weak Wi-Fi, no audio
$opts = @('--turn-screen-off', '--no-audio', '--max-size=1024', '--video-bit-rate=2M')
```

See the [scrcpy documentation](https://github.com/Genymobile/scrcpy#readme) for all options.

### Troubleshooting

- **"NOT AUTHORIZED":** unlock the phone and accept the USB debugging prompt. If it does not appear, use *Developer options → Revoke USB debugging authorizations*, then replug the cable. Set the USB mode to *File transfer*.
- **"No cable and Wi-Fi does not respond":** check that both devices are on the same network. If the phone rebooted or its IP changed, plug the cable in once.
- **Windows SmartScreen warning:** click *More info → Run anyway*. These are plain text files, so you can open and read them first.
- **"Running scripts is disabled":** the `.bat` starts PowerShell with `-ExecutionPolicy Bypass` for this script only and does not change any Windows setting.
- **The switch takes a few seconds:** expected. The window closes and reopens (about 2 to 4 seconds).

### Security

- Wireless mode leaves ADB listening on port 5555 **until the phone reboots**.
- New computers must still be authorized on the phone, but **avoid using this on public or unknown Wi-Fi**.
- `celular_ip.txt` is generated locally and is listed in `.gitignore`.

### Credits and license

- Created by [Titanio112](https://github.com/Titanio112)
- Built on top of [scrcpy](https://github.com/Genymobile/scrcpy) by [Genymobile](https://github.com/Genymobile) (Romain Vimont and contributors), Apache 2.0
- Script written with help from Claude (Anthropic)
- [MIT](LICENSE) applies only to the scripts in this repository. scrcpy has its own license.
