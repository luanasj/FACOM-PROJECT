#Carregar o assembly do Windows Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

#Criar um novo formulário
$form = New-Object System.Windows.Forms.Form
$form.Text = "FACOM-bot"
$form.Size = New-Object System.Drawing.Size(500,500)
$form.StartPosition = "CenterScreen"

#Criar controle de abas (TabControl)
$tabControl = New-Object System.Windows.Forms.TabControl
$tabControl.Dock = "Fill"

#Criar aba 1
$tabPage1 = New-Object System.Windows.Forms.TabPage
$tabPage1.Text = "Aba 1"

#Adicionando controls na Aba 1
$label1 = New-Object System.Windows.Forms.Label
$label1.Text = "Primeira Label da Aba 1"
$label1.Location = New-Object System.Drawing.Point(20,20)
$label1.Size = New-Object System.Drawing.Size(200,50)
$tabPage1.Controls.Add($label1) 

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