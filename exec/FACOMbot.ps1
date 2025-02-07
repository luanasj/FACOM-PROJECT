$pyhtonCommand = "node caminho/para/seu/arquivo"
$nodeCommand = "python caminho/para/seu/arquivo"
$logsPath = "caminho/para/logs"


# restart-projects.ps1

# Função para iniciar o projeto Node.js
function Start-NodeProject {
    Stop-Process -Name "node" -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 30
    Start-Process powershell -ArgumentList [string]::Concat("-NoExit -Command", $nodeCommand) -WindowStyle Hidden
}

# Função para iniciar o projeto Python
function Start-PythonProject {
    Stop-Process -Name "python" -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 30
    Start-Process powershell -ArgumentList [string]::Concat("-NoExit -Command", $pyhtonCommand) -WindowStyle Hidden
}

# Loop infinito para reiniciar os projetos de tempos em tempos
while ($true) {
    Start-NodeProject
    Start-PythonProject

    # Aguarde 10 minutos antes de reiniciar os projetos (600 segundos)
    Start-Sleep -Seconds 3600

    # Opcionalmente, você pode adicionar um log para verificar quando os projetos são reiniciados
    Add-Content -Path $logsPath -Value "Projetos reiniciados em: $(Get-Date)"
}