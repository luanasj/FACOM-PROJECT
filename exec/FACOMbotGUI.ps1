#Carregar o assembly do Windows Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

#Definindo medidas padrão da Janela
$windowWidth = 800
$windowHeight = 800
$horizontalPadding = 10
$verticalPadding = 10
$spaceBetween = 20
$buttonWidth = 80
$buttonHeight = 20

#Criar um novo formulário
$form = New-Object System.Windows.Forms.Form
$form.Text = "FACOM-bot"
$form.Size = New-Object System.Drawing.Size($windowWidth,$windowHeight)
$form.StartPosition = "CenterScreen"

#Criar controle de abas (TabControl)
$tabControl = New-Object System.Windows.Forms.TabControl
$tabControl.Dock = "Fill"

###Criando e Editando Aba 1

#Criar aba 1
$tabPage1 = New-Object System.Windows.Forms.TabPage
$tabPage1.Text = "Aba 1"

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

for($i=0;$i -lt 8;$i++){
    $descTextHeight = 80

    $x = 20
    $y = $verticalPadding +($descTextHeight + $spaceBetween)*$i

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
    $descText.Multiline = $true  # Permitir múltiplas linhas
    $descText.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
    #$descText.ForeColor = [System.Drawing.Color]::Blue 
    #$descText.BackColor = [System.Drawing.Color]::LightYellow
    $panel1.Controls.Add($descText)

    $section = @{selector = $menuLabel; title = $titleText; description = $descText}
    [void]$menuSection.Add($section)

}

$genericButton = New-Object System.Windows.Forms.Button
$genericButton.Location = New-Object System.Drawing.Point($buttonWidth,($form.ClientSize.Height-50))
$genericButton.Text = "click_me"
$genericButton.Add_Click({
   foreach ($selector in $menuSection) {
    #    Write-Host $selector.description.Text
   }
})

$tabPage1.Controls.Add($genericButton)


###Criando e Editando Aba 2

#Criar aba 2
$tabPage2 = New-Object System.Windows.Forms.TabPage
$tabPage2.Text = "Aba 2"

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

#Criando seções para links de pdf

$pdfLinksSection = [System.Collections.ArrayList]::new()

$pdfLinksAmount = 3

$linksTextBoxWidth = ($linksBoxWidth - 2*$horizontalPadding - $spaceBetween)/2
$linksTextBoxHeight = ($linksBoxHeight -  2*$verticalPadding - ($pdfLinksAmount-1)*$spaceBetween)/5

for($i = 0; $i -lt $pdfLinksAmount; $i++){
    $y = $verticalPadding + 10 + ($linksTextBoxHeight + $spaceBetween)*$i

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

#Group Box para links de artigos do site
$webGroupBox = New-Object System.Windows.Forms.GroupBox
$webGroupBox.Text = "Links de Artigos do Site"
$webGroupBox.Size = New-Object System.Drawing.Size($linksBoxWidth,$linksBoxHeight)
$webGroupBox.Location = New-Object System.Drawing.Point($horizontalPadding,($linksBoxHeight + $spaceBetween + $verticalPadding))
$webGroupBox.Padding = New-Object System.Windows.Forms.Padding(0)
$webGroupBox.Margin = New-Object System.Windows.Forms.Padding(0)
$panel2.Controls.Add($webGroupBox)

#Criando seções para links de pdf

$webLinksSection = [System.Collections.ArrayList]::new()

$webLinksAmount = 3

$linksTextBoxWidth = ($linksBoxWidth - 2*$horizontalPadding - $spaceBetween)/2
$linksTextBoxHeight = ($linksBoxHeight - 2*$verticalPadding - ($webLinksAmount-1)*$spaceBetween)/5

for($i = 0; $i -lt $webLinksAmount; $i++){
    $y = $verticalPadding + 10 + ($linksTextBoxHeight + $spaceBetween)*$i

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

#Adicionando Abas ao tab Control
$tabControl.TabPages.Add($tabPage1)
$tabControl.TabPages.Add($tabPage2)

#Adicionar TabControl no Form
$form.Controls.Add($tabControl)

#Mostrar caixa de diálogo
$form.ShowDialog()


