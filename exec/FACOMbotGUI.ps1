#Carregar o assembly do Windows Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

#Criar um novo formulário
$form = New-Object System.Windows.Forms.Form
$form.Text = "FACOM-bot"
$form.Size = New-Object System.Drawing.Size(800,800)
$form.StartPosition = "CenterScreen"

#Criar controle de abas (TabControl)
$tabControl = New-Object System.Windows.Forms.TabControl
$tabControl.Dock = "Fill"
#$tabControl.Font = New-Object System.Drawing.Font("Arial", 10)

#Criar aba 1
$tabPage1 = New-Object System.Windows.Forms.TabPage
$tabPage1.Text = "Aba 1"

#Adicionando Container/GroupBox para segmentar Aba 1
$groupBox1 = New-Object System.Windows.Forms.GroupBox
$groupBox1.Text = "Tópicos do Menu"
$groupBox1.Size = New-Object System.Drawing.Size(760,700)
$groupBox1.Location = New-Object System.Drawing.Point(20,20)
$tabPage1.Controls.Add($groupBox1)

#Adicionando Labels
$menuInfo = @()

for($i=0;$i -lt 8;$i++){
    $x = 20
    $y = 20+100*$i

    $menuLabel = New-Object System.Windows.Forms.Label
    $menuLabel.Text = $i+1
    $menuLabel.Location = New-Object System.Drawing.Point($x,$y)
    $menuLabel.Size = New-Object System.Drawing.Size(15,20)
    $groupBox1.Controls.Add($menuLabel)
    

    $titleText = New-Object System.Windows.Forms.TextBox
    #$titleText.Text = ""
    $titleText.Location = New-Object System.Drawing.Point(($x+30),$y)
    $titleText.Size = New-Object System.Drawing.Size((15*$x),20)
    $titleText.Multiline = $true
    $titleText.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
    $groupBox1.Controls.Add($titleText)
       
    $descText = New-Object System.Windows.Forms.TextBox
    #$descText.Text = ""
    $descText.Location = New-Object System.Drawing.Point((17*$x+45),$y)
    $descText.Size = New-Object System.Drawing.Size((20*$x),100)
    $descText.Multiline = $true  # Permitir múltiplas linhas
    $descText.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
    #$descText.ForeColor = [System.Drawing.Color]::Blue 
    #$descText.BackColor = [System.Drawing.Color]::LightYellow
    $groupBox1.Controls.Add($descText)

}


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


