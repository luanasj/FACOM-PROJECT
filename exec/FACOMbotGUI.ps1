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

$nodeCommand = "-NoExit -Command `"Set-Location $($env:commonPathBot)\venom_bot; node venom_bot.js`""
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
        $global:nodeProcess = Start-Process powershell -ArgumentList $nodeCommand  -PassThru -ErrorAction Stop

        Write-Output "Node.js process started with ID: $($global:nodeProcess.Id)"
    } catch {
        Write-Error "Erro ao iniciar o projeto Node.js: $_"
        Add-Content -Path $logsPath -Value "$(Get-Date) erro: $($_)"
    }
}

#Função para parar o Processo Python
function Stop-PythonProcess {
    Stop-Process -Name "python" -ErrorAction SilentlyContinue #python
    if($global:pythonProcess){
        Start-Sleep -Seconds 3
        Stop-Process -Id $global:pythonProcess.Id -Force -ErrorAction SilentlyContinue #powershell
    }
}

# Função para iniciar o projeto Python
function Start-PythonProcess {
    Stop-PythonProcess
    try {
        Start-Sleep -Seconds 10

        $global:pythonProcess = Start-Process powershell -ArgumentList $pyhtonCommand  -PassThru -ErrorAction Stop

        Write-Output "Python process started with ID: $($global:pythonProcess.Id)"
    } catch {
        Write-Error "Erro ao iniciar o projeto Python: $_"
        Add-Content -Path $logsPath -Value "$(Get-Date) erro: $($_)"
    }
}


# Função que será chamada na limpeza
function Cleanup {
    Write-Host "`nIniciando operações de limpeza..."
    
    try {
        # Write-Host "A execução do script foi interrompida em: $(Get-Date)"
        
        Stop-NodeProcess
        Stop-PythonProcess

        Write-Host "Removendo arquivos temporários..."
        # Especificar o caminho da pasta
        $pasta =  "$($env:commonPathBot)\venom_bot\tokens"
        Write-Host $pasta

        # Deletar a pasta e todos os seus conteúdos
        Remove-Item $pasta -Recurse -Force -ErrorAction SilentlyContinue

        # Write-Host "Fechando conexões..."
        # Write-Host "Liberando recursos..."
        Start-Sleep -Seconds 10
    }
    catch {
        Write-Host "Erro durante a limpeza: $_" -ForegroundColor Red
        Add-Content -Path $logsPath -Value "$(Get-Date) erro: $($_)"
    }
    finally {
        Write-Host "Operações de limpeza concluídas" -ForegroundColor Green
    }
}

# $global:checkProcessStatus = $true
function Update-Status {

    try {
       Get-Process -Name "python" -ErrorAction Stop
       Get-Process -Name "node" -ErrorAction Stop

       return "Chatbot: Processos ativos."
    }
    catch {
        return "Por favor inicie o chatbot"
    }

}

# Registra o manipulador de CTRL+C
$null = Register-EngineEvent -SourceIdentifier 'PowerShell.Exiting' -Action {
    # Write-Host "`nCTRL+C detectado!"
    Cleanup
}

# Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -Action $eventAction


#Carregar o assembly do Windows Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

#Definindo medidas padrão da Janela
$windowWidth = 800
$windowHeight = 800
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
$phoneNumber.PlaceholderText = "ex: 5511947270112"
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

            $newPhoneNumberToJSON = @{phoneNumber=$phoneNumber.Text} | ConvertTo-Json

            Set-Content -Path $utilInfoJSONPath -Value $newPhoneNumberToJSON
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

#Criando botão para iniciar programa
$startButton = New-Object System.Windows.Forms.Button
$startButton.Text = "Iniciar Bot"
$startButton.Size = New-Object System.Drawing.Size($buttonWidth,$buttonHeight)
$startButton.Location = New-Object System.Drawing.Point((($windowWidth - $buttonWidth)/2),(($windowHeight-100)*(1/4)))
$startButton.BackColor = [System.Drawing.Color]::FromArgb(255, 204,255,153) # Alfa, Vermelho, Verde, Azul
$mainTab.Controls.Add($startButton)

#Criando botão para Reiniciar
$restartButton = New-Object System.Windows.Forms.Button
$restartButton.Text = "Reiniciar Bot"
$restartButton.Size = New-Object System.Drawing.Size($buttonWidth,$buttonHeight)
$restartButton.Location = New-Object System.Drawing.Point((($windowWidth - $buttonWidth)/2),(($windowHeight-100)*(2/4)))
$restartButton.BackColor = [System.Drawing.Color]::FromArgb(255, 255,255,74)
$mainTab.Controls.Add($restartButton)

#Criando botão para Desligar
$turnOffButton = New-Object System.Windows.Forms.Button
$turnOffButton.Text = "Desligar Bot"
$turnOffButton.Size = New-Object System.Drawing.Size($buttonWidth,$buttonHeight)
$turnOffButton.Location = New-Object System.Drawing.Point((($windowWidth - $buttonWidth)/2),(($windowHeight-100)*(3/4)))
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
$groupBox1.Size = New-Object System.Drawing.Size($box1Width,$box1Height)
$groupBox1.Location = New-Object System.Drawing.Point($horizontalPadding,$verticalPadding)
$groupBox1.Padding = New-Object System.Windows.Forms.Padding(0)
$groupBox1.Margin = New-Object System.Windows.Forms.Padding(0)

$tabPage1.Controls.Add($groupBox1)

$panel1 = New-Object System.Windows.Forms.Panel
$panel1.AutoScroll = $true
$panel1.Size = New-Object System.Drawing.Size(($box1Width-(2*$horizontalPadding)),($box1Height-(4*$verticalPadding)))
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


for($i=0;$i -lt 8;$i++){
    $caminhoJSON = "$($env:commonPathBot)\assets\externalInfo.json"

    $jsonContent = Get-Content -Path $caminhoJSON -Raw

    $dados = $jsonContent | ConvertFrom-Json


    $descTextHeight = 80

    $x = 20
    $y = $menuSectionTitle.ClientSize.Height + ($descTextHeight + $spaceBetween)*$i

    $labelWidth = 15
    $labelHeight = 20
    $menuLabel = New-Object System.Windows.Forms.Label
    $menuLabel.Text = $i+1
    $menuLabel.Padding = New-Object System.Windows.Forms.Padding(0)
    $menuLabel.Margin = New-Object System.Windows.Forms.Padding(0)
    $menuLabel.Location = New-Object System.Drawing.Point(0,$y)
    $menuLabel.Size = New-Object System.Drawing.Size($labelWidth,$labelHeight)
    $panel1.Controls.Add($menuLabel)
    
    $textBoxesWidth = ($box1Width - $labelWidth- 2*$x - 2*$spaceBetween) / 2
     
    $titleTextX = $labelWidth + $spaceBetween
    $titleText = New-Object System.Windows.Forms.TextBox
    $titleText.Location = New-Object System.Drawing.Point($titleTextX,$y)
    if($i -lt $dados.Count){
        $titleText.Text = $dados[$i].name
    }
    $titleText.Margin = New-Object System.Windows.Forms.Padding(0)
    $titleText.Padding = New-Object System.Windows.Forms.Padding(0)
    $titleText.Size = New-Object System.Drawing.Size($textBoxesWidth,25)
    $titleText.Multiline = $true
    $titleText.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
    $panel1.Controls.Add($titleText) 

    $descTextX = $titleTextX + $textBoxesWidth + $spaceBetween
    $descText = New-Object System.Windows.Forms.TextBox
    $descText.Location = New-Object System.Drawing.Point($descTextX,$y)
    if($i -lt $dados.Count){
        $descText.Text = $dados[$i].description
    }
    $descText.Padding =New-Object System.Windows.Forms.Padding(0)
    $descText.Margin = New-Object System.Windows.Forms.Padding(0)
    $descText.Size = New-Object System.Drawing.Size($textBoxesWidth,$descTextHeight)
    $descText.Multiline = $true  
    $descText.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical

    $panel1.Controls.Add($descText)

    $section = @{selector = $menuLabel; title = $titleText; description = $descText}
    [void]$menuSection.Add($section)

}

$updateMenuButton = New-Object System.Windows.Forms.Button
$updateMenuButton.Location = New-Object System.Drawing.Point(($windowWidth - $buttonWidth - $horizontalPadding-30),($form.ClientSize.Height-$buttonHeight- 30))
$updateMenuButton.Size = New-Object System.Drawing.Size($buttonWidth,$buttonHeight)
$updateMenuButton.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$updateMenuButton.Text = "Atualizar Menu"
$updateMenuButton.Add_Click({
    $caminhoJSON = "$($env:commonPathBot)\assets\externalInfo.json"

    $dados = [System.Collections.ArrayList]::new()

    foreach ($selector in $menuSection) {
       if($selector.title.Text -and $selector.description.Text){
           [void]$dados.Add(@{name = selector.title.Text; description = $selector.description.Text})
       }
    #    Write-Host $selector.description.Text
   }

   $jsonAtualizado = $dados | ConvertTo-Json -Depth 10

   Set-Content -Path $caminhoJson -Value $jsonAtualizado
})

$tabPage1.Controls.Add($updateMenuButton)

###Criando e Editando Aba 2

#Criar aba 2
$tabPage2 = New-Object System.Windows.Forms.TabPage
$tabPage2.Text = "IA Info"

#Criando Panel 2
$panel2 = New-Object System.Windows.Forms.Panel
$panel2.AutoScroll = $true
$panel2.Size = New-Object System.Drawing.Size($form.ClientSize.Width,($form.ClientSize.Height - 30))
$panel2.Location = New-Object System.Drawing.Point(0,0)
$tabPage2.Controls.Add($panel2)

#Criando GroupBoxes da Aba 2
$linksBoxWidth = $form.ClientSize.Width - 2*3 - 2*$horizontalPadding
$linksBoxHeight = $form.ClientSize.Height / 2


#Group Box para links de pdf
$pdfGroupBox = New-Object System.Windows.Forms.GroupBox
$pdfGroupBox.Text = "Links de PDF"
$pdfGroupBox.Size = New-Object System.Drawing.Size($linksBoxWidth,$linksBoxHeight)
$pdfGroupBox.Location = New-Object System.Drawing.Point($horizontalPadding,$verticalPadding)
$pdfGroupBox.Padding = New-Object System.Windows.Forms.Padding(0)
$pdfGroupBox.Margin = New-Object System.Windows.Forms.Padding(0)
$panel2.Controls.Add($pdfGroupBox)

#Colocando titulo na sessão de links pdf 
$pdfSectionTitle = New-Object System.Windows.Forms.Label
$pdfSectionTitle.Text = "Título(Sem Espaços)                                                                   Link"
$pdfSectionTitle.Font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold)
$pdfSectionTitle.Location = New-Object System.Drawing.Point(100,$verticalPadding)
$pdfSectionTitle.Size = New-Object System.Drawing.Size(($box1Width - 100),20)
$pdfGroupBox.Controls.Add($pdfSectionTitle)


#Criando seções para links de pdf
$pdfLinksSection = [System.Collections.ArrayList]::new()

$pdfLinksAmount = 3

$linksTextBoxWidth = ($linksBoxWidth - 2*$horizontalPadding - $spaceBetween)/2
$linksTextBoxHeight = ($linksBoxHeight -  2*$verticalPadding - ($pdfLinksAmount-1)*$spaceBetween)/5

for($i = 0; $i -lt $pdfLinksAmount; $i++){
    $jsonPath = "$($env:commonPathBot)\assets\externalLinks.json"

    $jsonContent = Get-Content -Path $jsonPath -Raw 
    
    $dados = $jsonContent | ConvertFrom-Json 

    $pdfs = $dados.pdfs

    $y = $verticalPadding + $pdfSectionTitle.ClientSize.Height + ($linksTextBoxHeight + $spaceBetween)*$i

    $pdfDesc = New-Object System.Windows.Forms.TextBox
    $pdfDesc.Multiline = $true
    if($i -lt $pdfs.Count){
        $pdfDesc.Text = $pdfs[$i].title
    }
    $pdfDesc.Size = New-Object System.Drawing.Size($linksTextBoxWidth,$linksTextBoxHeight)
    $pdfDesc.Location = New-Object System.Drawing.Point($horizontalPadding, $y)
    $pdfGroupBox.Controls.Add($pdfDesc)

    $pdfLink = New-Object System.Windows.Forms.TextBox
    $pdfLink.Multiline = $true
    if($i -lt $pdfs.Count){
        $pdfLink.Text = $pdfs[$i].link
    }
    $pdfLink.Size = New-Object System.Drawing.Size($linksTextBoxWidth,$linksTextBoxHeight)
    $pdfLink.Location = New-Object System.Drawing.Point(($horizontalPadding + $linksTextBoxWidth + $spaceBetween), $y)
    $pdfGroupBox.Controls.Add($pdfLink)

    [void]$pdfLinksSection.Add(@{title = $pdfDesc; link = $pdfLink})
    
}

#Criando botão para atualizar pdf links

$updatePdfButton = New-Object System.Windows.Forms.Button
$updatePdfButton.Location = New-Object System.Drawing.Point(($pdfGroupBox.ClientSize.Width - $buttonWidth - $horizontalPadding),($pdfGroupBox.ClientSize.Height-$buttonHeight- $verticalPadding))
$updatePdfButton.Size = New-Object System.Drawing.Size($buttonWidth,$buttonHeight)
$updatePdfButton.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$updatePdfButton.Text = "Atualizar PDFs"
$updatePdfButton.Add_Click({
    $jsonPath = "$($env:commonPathBot)\assets\externalLinks.json"

    $jsonContent = Get-Content -Path $jsonPath -Raw 
    
    $dados = $jsonContent | ConvertFrom-Json 

    $novosDados = [System.Collections.ArrayList]::new()

    foreach($pdf in $pdfLinksSection){
        if($pdf.title.Text -and $pdf.link.Text){
            $novosDados.Add(@{title = $pdf.title.Text; link = $pdf.link.Text})
        }
    }

    $dados.pdfs = $novosDados

    $jsonAtualizado = $dados | ConvertTo-Json -Depth 10

    Set-Content -Path $jsonPath -Value $jsonAtualizado

    #    Write-Host $selector.description.Text
   
})

$pdfGroupBox.Controls.Add($updatePdfButton)


#Group Box para links de artigos do site
$webGroupBox = New-Object System.Windows.Forms.GroupBox
$webGroupBox.Text = "Links de Artigos do Site"
$webGroupBox.Size = New-Object System.Drawing.Size($linksBoxWidth,$linksBoxHeight)
$webGroupBox.Location = New-Object System.Drawing.Point($horizontalPadding,($linksBoxHeight + $spaceBetween + $verticalPadding))
$webGroupBox.Padding = New-Object System.Windows.Forms.Padding(0)
$webGroupBox.Margin = New-Object System.Windows.Forms.Padding(0)
$panel2.Controls.Add($webGroupBox)

#Colocando titulo na sessão de links web 
$webSectionTitle = New-Object System.Windows.Forms.Label
$webSectionTitle.Text = "Descrição                                                                         Link"
$webSectionTitle.Font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold)
$webSectionTitle.Location = New-Object System.Drawing.Point(150,$verticalPadding)
$webSectionTitle.Size = New-Object System.Drawing.Size(($box1Width - 100),20)
$webGroupBox.Controls.Add($webSectionTitle)

#Criando seções para links de pdf
$webLinksSection = [System.Collections.ArrayList]::new()

$webLinksAmount = 3

$linksTextBoxWidth = ($linksBoxWidth - 2*$horizontalPadding - $spaceBetween)/2
$linksTextBoxHeight = ($linksBoxHeight - 2*$verticalPadding - ($webLinksAmount-1)*$spaceBetween)/5

for($i = 0; $i -lt $webLinksAmount; $i++){
    $jsonPath = "$($env:commonPathBot)\assets\externalLinks.json"

    $jsonContent = Get-Content -Path $jsonPath -Raw 
    
    $dados = $jsonContent | ConvertFrom-Json 

    $webInfo = $dados.web

    $y = $verticalPadding + $webSectionTitle.ClientSize.Height + ($linksTextBoxHeight + $spaceBetween)*$i

    $webDesc = New-Object System.Windows.Forms.TextBox
    $webDesc.Multiline = $true
    if($i -lt $webInfo.Count){
        $webDesc.Text = $webInfo[$i].description
    }
    $webDesc.Size = New-Object System.Drawing.Size($linksTextBoxWidth,$linksTextBoxHeight)
    $webDesc.Location = New-Object System.Drawing.Point($horizontalPadding, $y)
    $webGroupBox.Controls.Add($webDesc)

    $webLink = New-Object System.Windows.Forms.TextBox
    $webLink.Multiline = $true
    if($i -lt $webInfo.Count){
        $webLink.Text = $webInfo[$i].link
    }
    $webLink.Size = New-Object System.Drawing.Size($linksTextBoxWidth,$linksTextBoxHeight)
    $webLink.Location = New-Object System.Drawing.Point(($horizontalPadding + $linksTextBoxWidth + $spaceBetween), $y)
    $webGroupBox.Controls.Add($webLink)

    [void]$webLinksSection.Add(@{desc = $webDesc; link = $webLink})
    
}

#Criando botão para atualizar pdf links

$updateWebButton = New-Object System.Windows.Forms.Button
$updateWebButton.Location = New-Object System.Drawing.Point(($webGroupBox.ClientSize.Width - $buttonWidth - $horizontalPadding),($webGroupBox.ClientSize.Height-$buttonHeight- $verticalPadding))
$updateWebButton.Size = New-Object System.Drawing.Size($buttonWidth,$buttonHeight)
$updateWebButton.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$updateWebButton.Text = "Atualizar Artigos Site"
$updateWebButton.Add_Click({

    $jsonPath = "$($env:commonPathBot)\assets\externalLinks.json"

    $jsonContent = Get-Content -Path $jsonPath -Raw 
    
    $dados = $jsonContent | ConvertFrom-Json 

    $novosDados = [System.Collections.ArrayList]::new()

    foreach($article in $webLinksSection){
        if($article.title.Text -and $article.link.Text){
            $novosDados.Add(@{title = $article.title.Text; link = $article.link.Text})
        }
    }

    $dados.web = $novosDados

    $jsonAtualizado = $dados | ConvertTo-Json -Depth 10

    Set-Content -Path $jsonPath -Value $jsonAtualizado

})

$WebGroupBox.Controls.Add($updateWebButton)


#Criando terceira aba para atualizar API-KEYS

$tabPage3 = New-Object System.Windows.Forms.TabPage
$tabPage3.Text = "API keys"

##Criando Título e Caixas de Texto para cada API-KEY

#Criando Label para API-KEY - Groq
$groqApiKeyLabel = New-Object System.Windows.Forms.Label
$groqApiKeyLabel.Text = "Groq:"
$groqApiKeyLabel.Name = ""
$groqApiKeyLabel.AutoSize = $true
$groqApiKeyLabel.Location = New-Object System.Drawing.Point($horizontalPadding,$verticalPadding)
$tabPage3.Controls.Add($groqApiKeyLabel)

#Criando TextBox para API-KEY - Groq
$groqApiKeyTextBox = New-Object System.Windows.Forms.TextBox
$groqApiKeyTextBox.Text = $env:GROQ_API_KEY
$groqApiKeyTextBox.Size = New-Object System.Drawing.Size(($windowWidth-20-$groqApiKeyLabel.ClientSize.Width - $spaceBetween - (2*$horizontalPadding)),$groqApiKeyLabel.ClientSize.Height)
$groqApiKeyTextBox.Location = New-Object System.Drawing.Point(($groqApiKeyLabel.Location.X + $groqApiKeyLabel.ClientSize.Width + $spaceBetween), $groqApiKeyLabel.Location.Y)
$groqApiKeyTextBox.Name = "GROQ_API_KEY"
$tabPage3.Controls.Add($groqApiKeyTextBox)

#Criando Label para API-KEY - LangChain
$langchainApiKeyLabel = New-Object System.Windows.Forms.Label
$langchainApiKeyLabel.Text = "Langchain:"
$langchainApiKeyLabel.AutoSize = $true
$langchainApiKeyLabel.Location = New-Object System.Drawing.Point($horizontalPadding,($groqApiKeyLabel.Location.X + $groqApiKeyLabel.ClientSize.Height + $spaceBetween))
$tabPage3.Controls.Add($langchainApiKeyLabel)

#Criando TextBox para API-KEY - LangChain
$langchainApiKeyTextBox = New-Object System.Windows.Forms.TextBox
$langchainApiKeyTextBox.Text = $env:LANGCHAIN_API_KEY
$langchainApiKeyTextBox.Size = New-Object System.Drawing.Size(($windowWidth-20-$langchainApiKeyLabel.ClientSize.Width - $spaceBetween - (2*$horizontalPadding)),$langchainApiKeyLabel.ClientSize.Height)
$langchainApiKeyTextBox.Location = New-Object System.Drawing.Point(($langchainApiKeyLabel.Location.X + $langchainApiKeyLabel.ClientSize.Width + $spaceBetween), $langchainApiKeyLabel.Location.Y)
$langchainApiKeyTextBox.Name = "LANGCHAIN_API_KEY"
$tabPage3.Controls.Add($langchainApiKeyTextBox)

#Criando Label para API-KEY - Tavily
$tavilyApiKeyLabel = New-Object System.Windows.Forms.Label
$tavilyApiKeyLabel.Text = "Tavily:"
$tavilyApiKeyLabel.AutoSize = $true
$tavilyApiKeyLabel.Location = New-Object System.Drawing.Point($horizontalPadding,($langchainApiKeyLabel.Location.Y + $langchainApiKeyLabel.ClientSize.Height + $spaceBetween))
$tabPage3.Controls.Add($tavilyApiKeyLabel)

#Criando TextBox para API-KEY - Tavily
$tavilyApiKeyTextBox = New-Object System.Windows.Forms.TextBox
$tavilyApiKeyTextBox.Text = $env:TAVILY_API_KEY
$tavilyApiKeyTextBox.Size = New-Object System.Drawing.Size(($windowWidth-20-$tavilyApiKeyLabel.ClientSize.Width - $spaceBetween - (2*$horizontalPadding)),$tavilyApiKeyLabel.ClientSize.Height)
$tavilyApiKeyTextBox.Location = New-Object System.Drawing.Point(($tavilyApiKeyLabel.Location.X + $tavilyApiKeyLabel.ClientSize.Width + $spaceBetween), $tavilyApiKeyLabel.Location.Y)
$tavilyApiKeyTextBox.Name = "TAVILY_API_KEY"
$tabPage3.Controls.Add($tavilyApiKeyTextBox)


#Criando Label para API-KEY - Cohere
$cohereApiKeyLabel = New-Object System.Windows.Forms.Label
$cohereApiKeyLabel.Text = "Cohere:"
$cohereApiKeyLabel.AutoSize = $true
$cohereApiKeyLabel.Location = New-Object System.Drawing.Point($horizontalPadding,($tavilyApiKeyLabel.Location.Y + $tavilyApiKeyLabel.ClientSize.Height + $spaceBetween))
$tabPage3.Controls.Add($cohereApiKeyLabel)

#Criando TextBox para API-KEY - Cohere
$cohereApiKeyTextBox = New-Object System.Windows.Forms.TextBox
$cohereApiKeyTextBox.Text = $env:COHERE_API_KEY
$cohereApiKeyTextBox.Size = New-Object System.Drawing.Size(($windowWidth-20-$cohereApiKeyLabel.ClientSize.Width - $spaceBetween - (2*$horizontalPadding)),$cohereApiKeyLabel.ClientSize.Height)
$cohereApiKeyTextBox.Location = New-Object System.Drawing.Point(($cohereApiKeyLabel.Location.X + $cohereApiKeyLabel.ClientSize.Width + $spaceBetween), $cohereApiKeyLabel.Location.Y)
$cohereApiKeyTextBox.Name = "COHERE_API_KEY"
$tabPage3.Controls.Add($cohereApiKeyTextBox)

#Criando Botão para atualizar API-Keys
$apiKeysUpdateBtn = New-Object System.Windows.Forms.Button
$apiKeysUpdateBtn.Text = "Atualizar Chaves"
$apiKeysUpdateBtn.AutoSize = $true
$tabPage3.Controls.Add($apiKeysUpdateBtn)
$apiKeysUpdateBtn.Location = New-Object System.Drawing.Point(($windowWidth -30- $apiKeysUpdateBtn.ClientSize.Width - (2*$horizontalPadding)),($cohereApiKeyTextBox.Location.Y + $cohereApiKeyTextBox.ClientSize.Height + $spaceBetween))

#Adicionando Função para atualizar API-Keys



$apiKeysUpdateBtn.Add_Click({
    $apiKeysTextBoxes = @($groqApiKeyTextBox,$langchainApiKeyTextBox,$tavilyApiKeyTextBox,$cohereApiKeyTextBox)

    # # Ler o conteúdo do arquivo .env
    $dotenvContent = Get-Content -Path "$($env:commonPathBot)\.env"

    $apiKeysUpdatedContent = $dotenvContent

    foreach ($keyTextBox in $apiKeysTextBoxes) {
        # Definir a chave que você quer alterar e o novo valor
        $key = $keyTextBox.Name
        $newValue = $keyTextBox.Text

        # Atualizar a linha correspondente à chave usando regex
        $apiKeysUpdatedContent = $apiKeysUpdatedContent -replace "($key\s*=\s*).*", "`$1$newValue"
    }

    # Salvar as alterações de volta no arquivo .env
    Set-Content -Path $envPath -Value $apiKeysUpdatedContent

    # Write-Output "O arquivo .env foi atualizado com sucesso!"

})

#Adicionando as Funções dos Botões do início
$startButton.Add_Click{
    Start-NodeProcess
    Start-PythonProcess 

    $mainTabStatus.Text = "Iniciando chatBot"
}

$restartButton.Add_Click{
    Cleanup
    Start-NodeProcess
    Start-PythonProcess

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
$tabControl.TabPages.Add($tabPage2)
$tabControl.TabPages.Add($tabPage3)

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
    
    # Você pode cancelar o fechamento da janela configurando $e.Cancel = $true
    # $e.Cancel = $true
    $botStatusChecktimer.Stop()
    Cleanup

})

#Mostrar caixa de diálogo
$form.ShowDialog()






