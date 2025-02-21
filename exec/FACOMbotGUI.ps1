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

# $tabControl.Size = New-Object System.Drawing.Size($windowWidth,$windowHeight)
#$tabControl.Font = New-Object System.Drawing.Font("Arial", 10)

#Criar aba 1
$tabPage1 = New-Object System.Windows.Forms.TabPage
$tabPage1.Text = "Aba 1"
# $tabPage1.Size = $tabControl.Size
# Write-Host $tabPage1.Width
# Write-Host $tabPage1.Padding


#Adicionando Container/GroupBox para segmentar Aba 1
$box1Width = $form.ClientSize.Width - 2*3 - 2*$horizontalPadding
$box1Height = $form.ClientSize.Height - $buttonHeight - 4*$verticalPadding

$groupBox1 = New-Object System.Windows.Forms.GroupBox
$groupBox1.Text = "Tópicos do Menu"
$groupBox1.Size = New-Object System.Drawing.Size($box1Width,$box1Height)
$groupBox1.Location = New-Object System.Drawing.Point($horizontalPadding,$verticalPadding)
$groupBox1.Padding = New-Object System.Windows.Forms.Padding(0)
$groupBox1.Margin = New-Object System.Windows.Forms.Padding(0)
# Write-Host $groupBox1.Padding
# Write-Host $groupBox1.Margin

$tabPage1.Controls.Add($groupBox1)


$panel1 = New-Object System.Windows.Forms.Panel
$panel1.AutoScroll = $true
$panel1.Size = New-Object System.Drawing.Size(($box1Width-(2*$horizontalPadding)),($box1Height-(4*$verticalPadding)))
# $panel1.Padding = New-Object System.Windows.Forms.Padding(2)
# $panel1.Margin = New-Object System.Windows.Forms.Padding(2)
$panel1.Location = New-Object System.Drawing.Point(($verticalPadding/2),(2*$verticalPadding))
$groupBox1.Controls.Add($panel1)

#Adicionando Labels
$menuSection = [System.Collections.ArrayList]::new()

for($i=0;$i -lt 8;$i++){
    $descTextHeight = 80

    $x = 20
    $y = 10+($descTextHeight + $spaceBetween)*$i


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
    #$titleText.Text = ""
    $titleText.Location = New-Object System.Drawing.Point($titleTextX,$y)
    $titleText.Margin = New-Object System.Windows.Forms.Padding(0)
    $titleText.Padding = New-Object System.Windows.Forms.Padding(0)
    $titleText.Size = New-Object System.Drawing.Size($textBoxesWidth,20)
    $titleText.Multiline = $true
    $titleText.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
    $panel1.Controls.Add($titleText)
       

    $descTextX = $titleTextX + $textBoxesWidth + $spaceBetween
    $descText = New-Object System.Windows.Forms.TextBox
    #$descText.Text = ""
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
$genericButton.Location = New-Object System.Drawing.Point(20,($form.ClientSize.Height-50))
$genericButton.Text = "click_me"
$genericButton.Add_Click({
    Write-Host "Hello"
})
$tabPage1.Controls.Add($genericButton)


#Adicionando controls no GroupBox1
#$label1 = New-Object System.Windows.Forms.Label
#$label1.Text = "Primeira Label da Aba 1"
#$label1.Location = New-Object System.Drawing.Point(20,20)
#$label1.Size = New-Object System.Drawing.Size(200,50)
#$groupBox1.Controls.Add($label1) 

#Criar aba 2
$tabPage2 = New-Object System.Windows.Forms.TabPage
$tabPage2.Text = "Aba 2"

#Adicionar Controls na Aba 2
$label2 = New-Object System.Windows.Forms.Label
$label2.Text = "Conteudo da Aba 2"
$label2.Location = New-Object System.Drawing.Point(20,20)
$label2.Size = New-Object System.Drawing.Size(500,500)
$tabPage2.Controls.Add($label2)


#Adicionando Abas ao tab Control
$tabControl.TabPages.Add($tabPage1)
$tabControl.TabPages.Add($tabPage2)

#Adicionar TabControl no Form
$form.Controls.Add($tabControl)

#Mostrar caixa de diálogo
$form.ShowDialog()


