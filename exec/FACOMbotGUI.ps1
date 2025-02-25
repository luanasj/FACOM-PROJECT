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



$pyhtonCommand = "-NoExit -Command node $($env:commonPathBot)\venom_bot\venom_bot.js"
$nodeCommand = "-NoExit -Command python -m flask --app $($env:commonPathBot)\AdaptativeRAG\langchain_bot.py run"
$logsPath = $env:commonPathBot + "\exec\logs.txt"

# Variáveis globais para os processos
$global:nodeProcess = $null
$global:pythonProcess = $null

# Função para iniciar o projeto Node.js
function Start-NodeProcess {
    try {
        Stop-Process -Name "node" -ErrorAction SilentlyContinue #node
        if ($global:nodeProcess) {
            Start-Sleep -Seconds 3
            Stop-Process  -Id $global:nodeProcess.Id -Force -ErrorAction SilentlyContinue #powershell
        }
        Start-Sleep -Seconds 60
        $global:nodeProcess = Start-Process powershell -ArgumentList $nodeCommand -PassThru
        Write-Output "Node.js process started with ID: $($global:nodeProcess.Id)"
    } catch {
        Write-Error "Erro ao iniciar o projeto Node.js: $_"
        Add-Content -Path $logsPath -Value "$(Get-Date) erro: $($_)"
    }
}

# Função para iniciar o projeto Python
function Start-PythonProcess {
    try {
        while ($true){
            Stop-Process -Name "python" -ErrorAction SilentlyContinue #python
            if($global:pythonProcess){
                Start-Sleep -Seconds 3
                Stop-Process -Id $global:pythonProcess.Id -Force -ErrorAction SilentlyContinue powershell
            }
            Start-Sleep -Seconds 20
            $global:pythonProcess = Start-Process powershell -ArgumentList $pyhtonCommand -PassThru
            Write-Output "Python process started with ID: $($global:pythonProcess.Id)"
            
            Start-Sleep -Seconds 3600
        }

    } catch {
        Write-Error "Erro ao iniciar o projeto Python: $_"
        Add-Content -Path $logsPath -Value "$(Get-Date) erro: $($_)"
    }
}


# Função que será chamada na limpeza
function Cleanup {
    Write-Host "`nIniciando operações de limpeza..."
    
    try {
        Write-Host "A execução do script foi interrompida em: $(Get-Date)"
        if ($global:nodeProcess) {
            Stop-Process -Name "node" -Force -ErrorAction Stop
            Start-Sleep -Seconds 3
            Stop-Process  -Id $global:nodeProcess.Id -Force -ErrorAction SilentlyContinue 
        }
        if ($global:pythonProcess) {
            Stop-Process -Name "python" -Force -ErrorAction Stop
            Start-Sleep -Seconds 3
            Stop-Process -Id $global:pythonProcess.Id -Force -ErrorAction SilentlyContinue 
        }
        Write-Host "Removendo arquivos temporários..."
        # Especificar o caminho da pasta
        $pasta =  "$($env:commonPathBot)\venom_bot"
        Write-Host $pasta

        # Deletar a pasta e todos os seus conteúdos
        Remove-Item $pasta -Recurse -Force -ErrorAction SilentlyContinue

        Write-Host "Fechando conexões..."
        Write-Host "Liberando recursos..."
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

# Registra o manipulador de CTRL+C
$null = Register-EngineEvent -SourceIdentifier 'PowerShell.Exiting' -Action {
    Write-Host "`nCTRL+C detectado!"
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


#Criando botão para iniciar programa
$startButton = New-Object System.Windows.Forms.Button
$startButton.Text = "Iniciar Bot"
$startButton.Size = New-Object System.Drawing.Size($buttonWidth,$buttonHeight)
$startButton.Location = New-Object System.Drawing.Point((($windowWidth - $buttonWidth)/2),(($windowHeight-100)*(1/4)))
$mainTab.Controls.Add($startButton)

#Criando botão para Reiniciar
$restartButton = New-Object System.Windows.Forms.Button
$restartButton.Text = "Reiniciar Bot"
$restartButton.Size = New-Object System.Drawing.Size($buttonWidth,$buttonHeight)
$restartButton.Location = New-Object System.Drawing.Point((($windowWidth - $buttonWidth)/2),(($windowHeight-100)*(2/4)))
$mainTab.Controls.Add($restartButton)

#Criando botão para Desligar
$turnOffButton = New-Object System.Windows.Forms.Button
$turnOffButton.Text = "Desligar Bot"
$turnOffButton.Size = New-Object System.Drawing.Size($buttonWidth,$buttonHeight)
$turnOffButton.Location = New-Object System.Drawing.Point((($windowWidth - $buttonWidth)/2),(($windowHeight-100)*(3/4)))
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
    $caminhoJSON = "$($env:commonPathBot)\externalInfo.json"

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
    $caminhoJSON = "$($env:commonPathBot)\externalInfo.json"

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
    $jsonPath = "$($env:commonPathBot)\externalLinks.json"

    $jsonContent = Get-Content -Path $jsonPath -Raw 
    
    $dados = $jsonContent | ConvertFrom-Json 

    $pdfs = $dados.pdfs

    $y = $verticalPadding + $pdfSectionTitle.ClientSize.Height + ($linksTextBoxHeight + $spaceBetween)*$i

    $pdfDesc = New-Object System.Windows.Forms.TextBox
    $pdfDesc.Multiline = $true
    if($i -lt $pdfs.Count){
        $pdfDesc.Text = pdfs[$i].title
    }
    $pdfDesc.Size = New-Object System.Drawing.Size($linksTextBoxWidth,$linksTextBoxHeight)
    $pdfDesc.Location = New-Object System.Drawing.Point($horizontalPadding, $y)
    $pdfGroupBox.Controls.Add($pdfDesc)

    $pdfLink = New-Object System.Windows.Forms.TextBox
    $pdfLink.Multiline = $true
    if($i -lt $pdfs.Count){
        $pdfLink.Text = pdfs[$i].link
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
    $jsonPath = "$($env:commonPathBot)\externalLinks.json"

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
    $jsonPath = "$($env:commonPathBot)\externalLinks.json"

    $jsonContent = Get-Content -Path $jsonPath -Raw 
    
    $dados = $jsonContent | ConvertFrom-Json 

    $webInfo = $dados.web

    $y = $verticalPadding + $webSectionTitle.ClientSize.Height + ($linksTextBoxHeight + $spaceBetween)*$i

    $webDesc = New-Object System.Windows.Forms.TextBox
    $webDesc.Multiline = $true
    if($i -lt $pdfs.Count){
        $webDesc.Text = $webInfo[$i].description
    }
    $webDesc.Size = New-Object System.Drawing.Size($linksTextBoxWidth,$linksTextBoxHeight)
    $webDesc.Location = New-Object System.Drawing.Point($horizontalPadding, $y)
    $webGroupBox.Controls.Add($webDesc)

    $webLink = New-Object System.Windows.Forms.TextBox
    $webLink.Multiline = $true
    if($i -lt $pdfs.Count){
        $webLink.Text = $webLink[$i].link
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

    $jsonPath = "$($env:commonPathBot)\externalLinks.json"

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

#Adicionando as Funções dos Botões do início
$startButton.Add_Click{
    Start-NodeProcess
    Start-PythonProcess
}

$restartButton.Add_Click{
    Cleanup
    Start-NodeProcess
    Start-PythonProcess

}

$turnOffButton.Add_Click{
    Cleanup
}


#Adicionando Abas ao tab Control
$tabControl.TabPages.Add($mainTab)
$tabControl.TabPages.Add($tabPage1)
$tabControl.TabPages.Add($tabPage2)

#Adicionar TabControl no Form
$form.Controls.Add($tabControl)

$form.add_FormClosing({
    param([System.Object]$sender, [System.Windows.Forms.FormClosingEventArgs]$e)
    Write-Host "A janela está prestes a ser fechada."
    # Você pode cancelar o fechamento da janela configurando $e.Cancel = $true
    # $e.Cancel = $true

    Cleanup
})

#Mostrar caixa de diálogo
$form.ShowDialog()


