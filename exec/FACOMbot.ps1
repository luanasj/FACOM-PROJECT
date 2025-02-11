$pyhtonCommand = "-NoExit -Command node C:\Users\luana\OneDrive\Documentos\FACOM-Project\Agents\venom_bot\venom_bot.js"
$nodeCommand = "-NoExit -Command python -m flask --app C:\Users\luana\OneDrive\Documentos\FACOM-Project\Agents\AdaptativeRAG\langchain_bot.py run"
$logsPath = "C:\Users\luana\OneDrive\Documentos\FACOM-Project\Agents\exec\logs.txt"


# restart-projects.ps1

# Função para iniciar o projeto Node.js
function Start-NodeProject {
    Stop-Process -Name "node" -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 30
    # Start-Process powershell -ArgumentList $nodeCommand -WindowStyle Hidden
    Start-Process powershell -ArgumentList $nodeCommand -PassThru
}

# Função para iniciar o projeto Python
function Start-PythonProject {
    Stop-Process -Name "python" -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 30
    # Start-Process powershell -ArgumentList  $pyhtonCommand -WindowStyle Hidden
    Start-Process powershell -ArgumentList  $pyhtonCommand -PassThru
}

# $nodeProcess, $PythonProcess

# Loop infinito para reiniciar os projetos de tempos em tempos
while ($true) {
    # $nodeProcess = Start-NodeProject
    # $PythonProcess = Start-PythonProject

    # Aguarde 10 minutos antes de reiniciar os projetos (600 segundos)
    Start-Sleep -Seconds 3600

    # Opcionalmente, você pode adicionar um log para verificar quando os projetos são reiniciados
    Add-Content -Path $logsPath -Value "Projetos reiniciados em: $(Get-Date)"
}

# Define a ação a ser executada quando o script for interrompido
$exitAction = {
    Write-Output "A execução do script foi interrompida em: $(Get-Date)"
    Stop-Process -Name "node" -ErrorAction SilentlyContinue
    Stop-Process -Name "python" -ErrorAction SilentlyContinue
}

# Registra o evento de interrupção do PowerShell
Register-EngineEvent -SourceIdentifier PowerShell.Exiting -Action $exitAction