$pyhtonCommand = "-NoExit -Command node C:\Users\luana\OneDrive\Documentos\FACOM-Project\Agents\venom_bot\venom_bot.js"
$nodeCommand = "-NoExit -Command python -m flask --app C:\Users\luana\OneDrive\Documentos\FACOM-Project\Agents\AdaptativeRAG\langchain_bot.py run"
$logsPath = "C:\Users\luana\OneDrive\Documentos\FACOM-Project\Agents\exec\logs.txt"

# Variáveis globais para os processos
$global:nodeProcess = $null
$global:pythonProcess = $null

# Função para iniciar o projeto Node.js
function Start-NodeProject {
    try {
        Stop-Process -Name "node" -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 30
        $global:nodeProcess = Start-Process powershell -ArgumentList $nodeCommand -PassThru
        Write-Output "Node.js process started with ID: $($global:nodeProcess.Id)"
    } catch {
        Write-Error "Erro ao iniciar o projeto Node.js: $_"
    }
}

# Função para iniciar o projeto Python
function Start-PythonProject {
    try {
        Stop-Process -Name "python" -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 30
        $global:pythonProcess = Start-Process powershell -ArgumentList $pyhtonCommand -PassThru
        Write-Output "Python process started with ID: $($global:pythonProcess.Id)"
    } catch {
        Write-Error "Erro ao iniciar o projeto Python: $_"
    }
}

# Define a ação a ser executada quando o script for interrompido
$exitAction = {
    Write-Output "A execução do script foi interrompida em: $(Get-Date)"
    if ($global:nodeProcess) {
        Stop-Process -Force -Id $global:nodeProcess.Id  -ErrorAction SilentlyContinue
    }
    if ($global:pythonProcess) {
        Stop-Process -Force -Id $global:pythonProcess.Id -ErrorAction SilentlyContinue
    }
}

# Registra o evento de interrupção do PowerShell
Register-EngineEvent -SourceIdentifier PowerShell.Exiting -Action $exitAction
Register-EngineEvent -SourceIdentifier ConsoleBreak -Action $exitAction
$null = Register-EngineEvent -SourceIdentifier ConsoleCancelEvent -Action $exitAction



# Loop infinito para reiniciar os projetos de tempos em tempos
while ($true) {
    Start-NodeProject
    Start-PythonProject

    # Aguarde 1 hora antes de reiniciar os projetos (3600 segundos)
    Start-Sleep -Seconds 3600

    # Opcionalmente, você pode adicionar um log para verificar quando os projetos são reiniciados
    Add-Content -Path $logsPath -Value "Projetos reiniciados em: $(Get-Date)"
}