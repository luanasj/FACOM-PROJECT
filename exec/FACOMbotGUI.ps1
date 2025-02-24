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
$mainTab.Controls.Add($startButton)

#Criando botão para Reiniciar
$restartButton = New-Object System.Windows.Forms.Button
$restartButton.Text = "Reiniciar Bot"
$mainTab.Controls.Add($restartButton)

#Criando botão para Desligar
$turnOffButton = New-Object System.Windows.Forms.Button
$turnOffButton.Text = "Desligar Bot"
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
    $titleText.Margin = New-Object System.Windows.Forms.Padding(0)
    $titleText.Padding = New-Object System.Windows.Forms.Padding(0)
    $titleText.Size = New-Object System.Drawing.Size($textBoxesWidth,25)
    $titleText.Multiline = $true
    $titleText.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
    $panel1.Controls.Add($titleText) 

    $descTextX = $titleTextX + $textBoxesWidth + $spaceBetween
    $descText = New-Object System.Windows.Forms.TextBox
    $descText.Location = New-Object System.Drawing.Point($descTextX,$y)
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
   foreach ($selector in $menuSection) {
    #    Write-Host $selector.description.Text
   }
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
$pdfSectionTitle.Text = "Descrição                                                                         Link"
$pdfSectionTitle.Font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold)
$pdfSectionTitle.Location = New-Object System.Drawing.Point(150,$verticalPadding)
$pdfSectionTitle.Size = New-Object System.Drawing.Size(($box1Width - 100),20)
$pdfGroupBox.Controls.Add($pdfSectionTitle)


#Criando seções para links de pdf
$pdfLinksSection = [System.Collections.ArrayList]::new()

$pdfLinksAmount = 3

$linksTextBoxWidth = ($linksBoxWidth - 2*$horizontalPadding - $spaceBetween)/2
$linksTextBoxHeight = ($linksBoxHeight -  2*$verticalPadding - ($pdfLinksAmount-1)*$spaceBetween)/5

for($i = 0; $i -lt $pdfLinksAmount; $i++){
    $y = $verticalPadding + $pdfSectionTitle.ClientSize.Height + ($linksTextBoxHeight + $spaceBetween)*$i

    $pdfDesc = New-Object System.Windows.Forms.TextBox
    $pdfDesc.Multiline = $true
    $pdfDesc.Size = New-Object System.Drawing.Size($linksTextBoxWidth,$linksTextBoxHeight)
    $pdfDesc.Location = New-Object System.Drawing.Point($horizontalPadding, $y)
    $pdfGroupBox.Controls.Add($pdfDesc)

    $pdfLink = New-Object System.Windows.Forms.TextBox
    $pdfLink.Multiline = $true
    $pdfLink.Size = New-Object System.Drawing.Size($linksTextBoxWidth,$linksTextBoxHeight)
    $pdfLink.Location = New-Object System.Drawing.Point(($horizontalPadding + $linksTextBoxWidth + $spaceBetween), $y)
    $pdfGroupBox.Controls.Add($pdfLink)

    [void]$pdfLinksSection.Add(@{desc = $pdfDesc; link = $pdfLink})
    
}

#Criando botão para atualizar pdf links

$updatePdfButton = New-Object System.Windows.Forms.Button
$updatePdfButton.Location = New-Object System.Drawing.Point(($pdfGroupBox.ClientSize.Width - $buttonWidth - $horizontalPadding),($pdfGroupBox.ClientSize.Height-$buttonHeight- $verticalPadding))
$updatePdfButton.Size = New-Object System.Drawing.Size($buttonWidth,$buttonHeight)
$updatePdfButton.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$updatePdfButton.Text = "Atualizar PDFs"
$updatePdfButton.Add_Click({
   
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
    $y = $verticalPadding + $webSectionTitle.ClientSize.Height + ($linksTextBoxHeight + $spaceBetween)*$i

    $webDesc = New-Object System.Windows.Forms.TextBox
    $webDesc.Multiline = $true
    $webDesc.Size = New-Object System.Drawing.Size($linksTextBoxWidth,$linksTextBoxHeight)
    $webDesc.Location = New-Object System.Drawing.Point($horizontalPadding, $y)
    $webGroupBox.Controls.Add($webDesc)

    $webLink = New-Object System.Windows.Forms.TextBox
    $webLink.Multiline = $true
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
   
    #    Write-Host $selector.description.Text
   
})

$WebGroupBox.Controls.Add($updateWebButton)

#Adicionando as Funções dos Botões do início
$startButton.Add_Click{

}

$restartButton.Add_Click{

}

$turnOffButton.Add_Click{
    
}


#Adicionando Abas ao tab Control
$tabControl.TabPages.Add($mainTab)
$tabControl.TabPages.Add($tabPage1)
$tabControl.TabPages.Add($tabPage2)

#Adicionar TabControl no Form
$form.Controls.Add($tabControl)

#Mostrar caixa de diálogo
$form.ShowDialog()


