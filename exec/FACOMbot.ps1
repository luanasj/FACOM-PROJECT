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
        if ($global:nodeProcess) {
            Start-Sleep -Seconds 3
            Stop-Process  -Id $global:nodeProcess.Id -Force -ErrorAction SilentlyContinue 
        }
        Start-Sleep -Seconds 20
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
        if($global:pythonProcess){
            Start-Sleep -Seconds 3
            Stop-Process -Id $global:pythonProcess.Id -Force -ErrorAction SilentlyContinue 
        }
        Start-Sleep -Seconds 20
        $global:pythonProcess = Start-Process powershell -ArgumentList $pyhtonCommand -PassThru
        Write-Output "Python process started with ID: $($global:pythonProcess.Id)"
    } catch {
        Write-Error "Erro ao iniciar o projeto Python: $_"
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
        Write-Host "Fechando conexões..."
        Write-Host "Liberando recursos..."
        Start-Sleep -Seconds 10
    }
    catch {
        Write-Host "Erro durante a limpeza: $_" -ForegroundColor Red
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

try {
    Write-Host "Script iniciado. Pressione CTRL+C para encerrar..."
    
    # Seu código principal aqui
    while ($true) {
        Start-NodeProject
        Start-PythonProject

        # Aguarde 1 hora antes de reiniciar os projetos (3600 segundos)
        Start-Sleep -Seconds 3600

        # Opcionalmente, você pode adicionar um log para verificar quando os projetos são reiniciados
        Add-Content -Path $logsPath -Value "Projetos reiniciados em: $(Get-Date)"
    }
}
catch {
    Write-Host "`nErro não esperado: $_" -ForegroundColor Red
}
finally {
    # Esta parte SEMPRE será executada, mesmo com CTRL+C
    Cleanup
    # Limpa o evento registrado
    Get-EventSubscriber | Where-Object SourceIdentifier -eq 'PowerShell.Exiting' | Unregister-Event
}