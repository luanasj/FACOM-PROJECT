# Set-Location C:\Users\luana\OneDrive\Documentos\FACOM-Project\Agents
# Especificar o caminho para o arquivo .env
$envPath = ".\.env"

# Ler o conteúdo do arquivo .env
$envContent = Get-Content -Path $envPath

# Percorrer cada linha do arquivo .env
foreach ($line in $envContent) {
    # Ignorar linhas que são comentários ou estão vazias
    if ($line -match '^\s*#' -or [string]::IsNullOrWhiteSpace($line)) {
        continue
    }

    # Separar a linha em chave e valor
    $parts = $line -split '='
    $key = $parts[0].Trim()
    $value = $parts[1].Trim()

    # Configurar a variável de ambiente
    [System.Environment]::SetEnvironmentVariable($key, $value)
}

# $nodeCommand = "-NoExit -Command `"Set-Location $($env:commonPathBot)\venom_bot; node venom_bot.js`""

$nodeCommand = "-NoExit -Command `"Set-Location $($env:commonPathBot)\wwebjs; node bot.js`""
$pyhtonCommand = "-NoExit -Command uvicorn --app-dir $($env:commonPathBot)\AdaptativeRAG langchain_bot:asgi_app --host 127.0.0.1 --port 5000 --workers 4"
$logsPath = $env:commonPathBot + "\exec\logs.txt"

# Variáveis globais para os processos
$global:nodeProcess = $null
$global:pythonProcess = $null

#Função para parar projeto Node js
function Stop-NodeProcess {
    Stop-Process -Name "node" -ErrorAction SilentlyContinue #node
    if ($global:nodeProcess) {
        Start-Sleep -Seconds 3
        Stop-Process -Id $global:nodeProcess.Id -Force -ErrorAction SilentlyContinue #powershell
    }
}

# Função para iniciar o projeto Node.js
function Start-NodeProcess {
    Stop-NodeProcess

    try {
        Start-Sleep -Seconds 20
        $global:nodeProcess = Start-Process powershell -ArgumentList $nodeCommand  -PassThru -ErrorAction Stop -WindowStyle Hidden

        # Write-Output "Node.js process started with ID: $($global:nodeProcess.Id)"
    } catch {
        Write-Error "Erro ao iniciar o projeto Node.js: $_"
        Add-Content -Path $logsPath -Value "$(Get-Date) erro: $($_)"
    }
}


# Função que será chamada na limpeza
function Cleanup {
    # Write-Host "`nIniciando operações de limpeza..."
    
    try {
        # Write-Host "A execução do script foi interrompida em: $(Get-Date)"
        
        Stop-NodeProcess
        # Stop-PythonProcess

        # Write-Host "Removendo arquivos temporários..."
        # Especificar o caminho da pasta
        # $pasta =  "$($env:commonPathBot)\venom_bot\tokens"
        $pasta =  "$($env:commonPathBot)\wwebjs\.wwebjs_cache"

        # Write-Host $pasta

        # Deletar a pasta e todos os seus conteúdos
        Remove-Item $pasta -Recurse -Force -ErrorAction SilentlyContinue

        Start-Sleep -Seconds 10
    }
    catch {
        Write-Host "Erro durante a limpeza: $_" -ForegroundColor Red
        Add-Content -Path $logsPath -Value "$(Get-Date) erro: $($_)"
    }
    finally {
        # Write-Host "Operações de limpeza concluídas" -ForegroundColor Green
    }
}

function Update-Status {

    try {
       Get-Process -Name "node" -ErrorAction Stop

       return "Chatbot ativo."
    }
    catch {
        return "Por favor inicie o chatbot"
    }

}

# Registra o manipulador de CTRL+C
$null = Register-EngineEvent -SourceIdentifier 'PowerShell.Exiting' -Action {
    Cleanup
}

#Carregar o assembly do Windows Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

#Definindo medidas padrão da Janela
$windowWidth = 800
$windowHeight = 700
$horizontalPadding = 10
$verticalPadding = 10
$spaceBetween = 20
$buttonWidth = 200
$buttonHeight = 30

#Criar um novo formulário
$form = New-Object System.Windows.Forms.Form
$form.Text = "FACOM-bot"
$form.Size = New-Object System.Drawing.Size($windowWidth,$windowHeight)
$form.StartPosition = "CenterScreen"

#Criar controle de abas (TabControl)
$tabControl = New-Object System.Windows.Forms.TabControl
$tabControl.Dock = "Fill"

#Criando aba Inicial/Funções báseicas
$mainTab = New-Object System.Windows.Forms.TabPage
$mainTab.Text = "Início"

#Criando título da aba Principal
$mainTabTitle = New-Object System.Windows.Forms.Label
$mainTabTitle.Text = "Painel de Controle"
$mainTabTitle.Font = New-Object System.Drawing.Font("Arial", 15, [System.Drawing.FontStyle]::Bold)
$mainTabTitle.AutoSize = $true
$mainTab.Controls.Add($mainTabTitle)
$mainTabTitle.Location = New-Object System.Drawing.Point((($windowWidth - $mainTabTitle.ClientSize.Width)/2),$verticalPadding)

#Criando Status do Painel de Controle/Aba Principal
$mainTabStatus = New-Object System.Windows.Forms.Label
$mainTabStatus.Text = "Por favor, inicie o sistema."
$mainTabStatus.Size = New-Object System.Drawing.Size($windowWidth, 20)
$mainTabStatus.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$mainTabStatus.Location = New-Object System.Drawing.Point(0,($verticalPadding+$spaceBetween+$mainTabTitle.ClientSize.Height))
$mainTab.Controls.Add($mainTabStatus)

#Capturando o número de telefone no json
$utilInfoJSONPath = "$($env:commonPathBot)\assets\utilInfo.json"
$utilInfoData = Get-Content -Path $utilInfoJSONPath -Raw
$utilInfoContent = $utilInfoData | ConvertFrom-Json

##Criando campo para adicionar número de telefone
$phoneNumber = New-Object System.Windows.Forms.TextBox
# $phoneNumber.PlaceholderText = "ex: 5511947270112"
$phoneNumber.Text = $utilInfoContent.phoneNumber
$phoneNumber.Size = New-Object System.Drawing.Size(200,20)
$mainTab.Controls.Add($phoneNumber)

#Criando Label para telefone
$phoneNumberLabel = New-Object System.Windows.Forms.Label
$phoneNumberLabel.Text = "Celular:"
$phoneNumberLabel.AutoSize = $true
$phoneNumberLabel.Font = New-Object System.Drawing.Font("Arial",10,[System.Drawing.FontStyle]::Bold)
$mainTab.Controls.Add($phoneNumberLabel)

#Criando Caixa de Texto para sinalizar erro
$invalidNumberWarning = New-Object System.Windows.Forms.Label
$invalidNumberWarning.ForeColor = [System.Drawing.Color]::Red
$invalidNumberWarning.Text = ""
$invalidNumberWarning.Font = New-Object System.Drawing.Font("Arial",8)
$invalidNumberWarning.AutoSize = $true
$mainTab.Controls.Add($invalidNumberWarning)

#Criando botão para atualizar número de celular
$phoneNumberUpdateBtn = New-Object System.Windows.Forms.Button
$phoneNumberUpdateBtn.Text = "Atualizar"
$phoneNumberUpdateBtn.AutoSize = $true
$phoneNumberUpdateBtn.Add_Click(
    {
        if(($phoneNumber.Text.Length -eq 13) -and ($phoneNumber.Text -match '^\d+$')){
            $invalidNumberWarning.Text = ""

            $utilInfoContent.phoneNumber = $phoneNumber.Text

            $newPhoneNumberToJSON = $utilInfoContent | ConvertTo-Json

            Set-Content -Encoding utf8 -Path $utilInfoJSONPath -Value $newPhoneNumberToJSON
        } else {
            $invalidNumberWarning.Text = "Número inválido, tente novamente. (Ex: 5571999999999)"  
            
        }
    }
)
$mainTab.Controls.Add($phoneNumberUpdateBtn)

#Posicionando os campos de número de celular
$phoneNumberInicialPosX = ($windowWidth-$phoneNumber.ClientSize.Width-$phoneNumberLabel.ClientSize.Width-$phoneNumberUpdateBtn.ClientSize.Width-(2*$spaceBetween))/2
$phoneNumberInicialPosY = $mainTabStatus.Location.Y + $mainTabStatus.ClientSize.Height + $spaceBetween  
$phoneNumberLabel.Location = New-Object System.Drawing.Point($phoneNumberInicialPosX,$phoneNumberInicialPosY)
$phoneNumber.Location = New-Object System.Drawing.Point(($phoneNumberInicialPosX+ $phoneNumberLabel.ClientSize.Width + $spaceBetween),$phoneNumberInicialPosY)
$phoneNumberUpdateBtn.Location = New-Object System.Drawing.Point(($phoneNumber.Location.X+$phoneNumber.ClientSize.Width + $spaceBetween),$phoneNumberInicialPosY)
$invalidNumberWarning.Location = New-Object System.Drawing.Point($phoneNumber.Location.X,($phoneNumber.Location.Y+$phoneNumber.ClientSize.Height+10))

##Criando campo para atualizar saudação inicial
$greetingText = New-Object System.Windows.Forms.TextBox
# $greetingText.PlaceholderText = "ex: 5511947270112"
$greetingText.Text = $utilInfoContent.greetingText
$greetingText.Size = New-Object System.Drawing.Size(200,60)
$greetingText.Multiline = $true
$mainTab.Controls.Add($greetingText)

#Criando Label para a saudação
$greetingTextLabel = New-Object System.Windows.Forms.Label
$greetingTextLabel.Text = "Saudação:"
$greetingTextLabel.AutoSize = $true
$greetingTextLabel.Font = New-Object System.Drawing.Font("Arial",10,[System.Drawing.FontStyle]::Bold)
$mainTab.Controls.Add($greetingTextLabel)

#Criando botão para atualizar número de celular
$greetingTextUpdateBtn = New-Object System.Windows.Forms.Button
$greetingTextUpdateBtn.Text = "Atualizar"
$greetingTextUpdateBtn.AutoSize = $true
$greetingTextUpdateBtn.Add_Click(
    {

            $utilInfoContent.greetingText = $greetingText.Text

            $newGreetingTextToJSON = $utilInfoContent | ConvertTo-Json

            Set-Content -Encoding utf8 -Path $utilInfoJSONPath -Value $newGreetingTextToJSON
    }
)
$mainTab.Controls.Add($greetingTextUpdateBtn)

#Posicionando os campos de saudação
$greetingTextInicialPosX = ($windowWidth-$greetingText.ClientSize.Width-$greetingTextLabel.ClientSize.Width-$greetingTextUpdateBtn.ClientSize.Width-(2*$spaceBetween))/2
$greetingTextInicialPosY = $phoneNumber.Location.Y + $phoneNumber.ClientSize.Height + $spaceBetween  
$greetingTextLabel.Location = New-Object System.Drawing.Point($greetingTextInicialPosX,$greetingTextInicialPosY)
$greetingText.Location = New-Object System.Drawing.Point(($phoneNumber.Location.X),$greetingTextInicialPosY)
$greetingTextUpdateBtn.Location = New-Object System.Drawing.Point(($greetingText.Location.X+$greetingText.ClientSize.Width + $spaceBetween),$greetingTextInicialPosY)
$invalidNumberWarning.Location = New-Object System.Drawing.Point($greetingText.Location.X,($greetingText.Location.Y+$greetingText.ClientSize.Height+10))


#Criando botão para iniciar programa
$startButton = New-Object System.Windows.Forms.Button
$startButton.Text = "Iniciar Bot"
$startButton.Size = New-Object System.Drawing.Size($buttonWidth,$buttonHeight)
$startButton.Location = New-Object System.Drawing.Point((($windowWidth - $buttonWidth)/2),(($windowHeight-200)*(2/4)))
$startButton.BackColor = [System.Drawing.Color]::FromArgb(255, 204,255,153) # Alfa, Vermelho, Verde, Azul
$mainTab.Controls.Add($startButton)

#Criando botão para Reiniciar
$restartButton = New-Object System.Windows.Forms.Button
$restartButton.Text = "Reiniciar Bot"
$restartButton.Size = New-Object System.Drawing.Size($buttonWidth,$buttonHeight)
$restartButton.Location = New-Object System.Drawing.Point((($windowWidth - $buttonWidth)/2),(($windowHeight-200)*(3/4)))
$restartButton.BackColor = [System.Drawing.Color]::FromArgb(255, 255,255,74)
$mainTab.Controls.Add($restartButton)

#Criando botão para Desligar
$turnOffButton = New-Object System.Windows.Forms.Button
$turnOffButton.Text = "Desligar Bot"
$turnOffButton.Size = New-Object System.Drawing.Size($buttonWidth,$buttonHeight)
$turnOffButton.Location = New-Object System.Drawing.Point((($windowWidth - $buttonWidth)/2),(($windowHeight-200)*(4/4)))
$turnOffButton.BackColor = [System.Drawing.Color]::FromArgb(255, 255,50,43)
$mainTab.Controls.Add($turnOffButton)

#Criar aba de informações do Menu inicial
$tabPage1 = New-Object System.Windows.Forms.TabPage
$tabPage1.Text = "Menu Info"

#Adicionando Container/GroupBox para segmentar Aba 1
$box1Width = $form.ClientSize.Width - 2*3 - 2*$horizontalPadding
$box1Height = $form.ClientSize.Height - $buttonHeight - 4*$verticalPadding

$groupBox1 = New-Object System.Windows.Forms.GroupBox
$groupBox1.Text = "Tópicos do Menu"
$groupBox1.Size = New-Object System.Drawing.Size($box1Width,($box1Height - (4*$verticalPadding)))
$groupBox1.Location = New-Object System.Drawing.Point($horizontalPadding,$verticalPadding)
$groupBox1.Padding = New-Object System.Windows.Forms.Padding(0)
$groupBox1.Margin = New-Object System.Windows.Forms.Padding(0)

$tabPage1.Controls.Add($groupBox1)

$panel1 = New-Object System.Windows.Forms.Panel
$panel1.AutoScroll = $true
$panel1.Size = New-Object System.Drawing.Size(($box1Width-(2*$horizontalPadding)),($box1Height-(6*$verticalPadding)))
$panel1.Location = New-Object System.Drawing.Point(($verticalPadding/2),(2*$verticalPadding))
$groupBox1.Controls.Add($panel1)

#Adicionando Linhas
$menuSection = [System.Collections.ArrayList]::new()


$menuSectionTitle = New-Object System.Windows.Forms.Label
$menuSectionTitle.Text = "Tópico                                                                     Conteúdo"
$menuSectionTitle.Font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold)
$menuSectionTitle.Location = New-Object System.Drawing.Point(150,0)
$menuSectionTitle.Size = New-Object System.Drawing.Size(($box1Width - 100),20)
$panel1.Controls.Add($menuSectionTitle)

$caminhoJSON = "$($env:commonPathBot)\assets\externalInfo.json"
$jsonContent = Get-Content -Path $caminhoJSON -Raw
$dados = $jsonContent | ConvertFrom-Json

$subtopicCount = 4
$descTextHeight = 60
$topicHeight = 25
$subtopicRowHeight = $descTextHeight + 5
$spaceBetween = 10

for ($i = 0; $i -lt 8; $i++) {
    $baseY = $menuSectionTitle.ClientSize.Height + ($i * (($subtopicCount * $subtopicRowHeight) + $topicHeight + 2 * $spaceBetween))
    $labelWidth = 20
    $textBoxesWidth = ($box1Width - $labelWidth - 4 * $spaceBetween) / 2

    # Label numérico
    $menuLabel = New-Object System.Windows.Forms.Label
    $menuLabel.Text = $i + 1
    $menuLabel.Location = New-Object System.Drawing.Point(0, $baseY)
    $menuLabel.Size = New-Object System.Drawing.Size($labelWidth, $topicHeight)
    $panel1.Controls.Add($menuLabel)

    # Campo Topic
    $topicText = New-Object System.Windows.Forms.TextBox
    $topicText.Location = New-Object System.Drawing.Point(($labelWidth + $spaceBetween), $baseY)
    $topicText.Size = New-Object System.Drawing.Size(($box1Width - $labelWidth - 2 * $spaceBetween), $topicHeight)
    if ($i -lt $dados.Count) {
        $topicText.Text = $dados[$i].topic
    }
    $panel1.Controls.Add($topicText)

    $subtopicsBoxes = @()

    for ($j = 0; $j -lt $subtopicCount; $j++) {
        $subY = $baseY + $topicHeight + $spaceBetween + $j * $subtopicRowHeight
        $nameBox = New-Object System.Windows.Forms.TextBox
        $nameBox.Location = New-Object System.Drawing.Point(($labelWidth + $spaceBetween), $subY)
        $nameBox.Size = New-Object System.Drawing.Size($textBoxesWidth, 25)

        $descBox = New-Object System.Windows.Forms.TextBox
        $descBox.Location = New-Object System.Drawing.Point(($labelWidth + 2 * $spaceBetween + $textBoxesWidth), $subY)
        $descBox.Size = New-Object System.Drawing.Size($textBoxesWidth, $descTextHeight)
        $descBox.Multiline = $true
        $descBox.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical

        if ($i -lt $dados.Count -and $dados[$i].subtopics.Count -gt $j) {
            $nameBox.Text = $dados[$i].subtopics[$j].name
            $descBox.Text = $dados[$i].subtopics[$j].description
        }

        $panel1.Controls.Add($nameBox)
        $panel1.Controls.Add($descBox)
        $subtopicsBoxes += @{ name = $nameBox; descricao = $descBox }
    }

    $section = @{
        topic     = $topicText
        subtopics = $subtopicsBoxes
    }

    [void]$menuSection.Add($section)
}

# Botão para atualizar o JSON
$updateMenuButton = New-Object System.Windows.Forms.Button
$updateMenuButton.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
$updateMenuButton.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$updateMenuButton.Text = "Atualizar Menu"
$updateMenuButton.Location = New-Object System.Drawing.Point(($windowWidth - $buttonWidth - $horizontalPadding - 30), ($form.ClientSize.Height - $buttonHeight - 30))

$updateMenuButton.Add_Click({
    $caminhoJson = "$($env:commonPathBot)\assets\externalInfo.json"
    $novoDados = @()

    foreach ($section in $menuSection) {
        $topic = $section.topic.Text
        $subtopics = @()

        foreach ($sub in $section.subtopics) {
            $name = $sub.name.Text
            $desc = $sub.descricao.Text
            if ($name -and $desc) {
                $subtopics += @{ name = $name; description = $desc }
            }
        }

        if ($topic) {
            $novoItem = @{
                topic     = $topic
                subtopics = $subtopics
            }
            $novoDados += $novoItem
        }
    }

    $jsonFinal = $novoDados | ConvertTo-Json -Depth 10
    Set-Content -Encoding utf8 -Path $caminhoJson -Value $jsonFinal
})

$updateMenuButton.Location = New-Object System.Drawing.Point(($windowWidth - $buttonWidth - $horizontalPadding-30),($form.ClientSize.Height-$buttonHeight- 30))
$tabPage1.Controls.Add($updateMenuButton)

#Adicionando as Funções dos Botões do início
$startButton.Add_Click{
    Start-NodeProcess
    $mainTabStatus.Text = "Iniciando chatBot"
}

$restartButton.Add_Click{
    Cleanup
    Start-NodeProcess
    $mainTabStatus.Text = "Reiniciando..."

}

$turnOffButton.Add_Click{
    $mainTabStatus.Text = "Desativando Chatbot, por favor aguarde um momento"
    Cleanup
    $mainTabStatus.Text = "Processo finalizado"
}


#Adicionando Abas ao tab Control
$tabControl.TabPages.Add($mainTab)
$tabControl.TabPages.Add($tabPage1)

#Adicionar TabControl no Form
$form.Controls.Add($tabControl)

$botStatusChecktimer = New-Object System.Timers.Timer
$botStatusChecktimer.Interval = 300 * 1000 #300seg * 1000, ou seja 5 minutos em milisegundos
$botStatusChecktimer.AutoReset = $true
$botStatusChecktimer.add_Elapsed({
    $mainTabStatus.Text = Update-Status
})

$form.add_FormClosing({
    param([System.Object]$sender, [System.Windows.Forms.FormClosingEventArgs]$e)
    
    Write-Host "A janela está prestes a ser fechada."
    
    $botStatusChecktimer.Stop()
    Cleanup

})

#Mostrar caixa de diálogo
$form.ShowDialog()






