$nodeCommand = "Set-Location $($env:commonPathBot)\venom_bot; -NoExit -Command node $($env:commonPathBot)\venom_bot\venom_bot.js"
$pyhtonCommand = "-NoExit -Command uvicorn --app-dir $($env:commonPathBot)\AdaptativeRAG langchain_bot:asgi_app --host 127.0.0.1 --port 5000 --workers 4 --reload"
$logsPath = $env:commonPathBot + "\exec\logs.txt"

# Variáveis globais para os processos
$global:nodeProcess = $null
$global:pythonProcess = $null


#Função para parar projeto Node js
function Stop-NodeProcess {
    Stop-Process -Name "node" -ErrorAction SilentlyContinue #node
    if ($global:nodeProcess) {
        Start-Sleep -Seconds 3
        Stop-Process -Id $global:nodeProcess.Id -Force -ErrorAction SilentlyContinue #powershell
    }
}

# Função para iniciar o projeto Node.js
function Start-NodeProcess {
    Stop-NodeProcess

    try {
        Start-Sleep -Seconds 20
        $global:nodeProcess = Start-Process powershell -ArgumentList $nodeCommand -PassThru -ErrorAction Stop

        Write-Output "Node.js process started with ID: $($global:nodeProcess.Id)"
    } catch {
        Write-Error "Erro ao iniciar o projeto Node.js: $_"
        Add-Content -Path $logsPath -Value "$(Get-Date) erro: $($_)"
    }
}

#Função para parar o Processo Python
function Stop-PythonProcess {
    Stop-Process -Name "python" -ErrorAction SilentlyContinue #python
    if($global:pythonProcess){
        Start-Sleep -Seconds 3
        Stop-Process -Id $global:pythonProcess.Id -Force -ErrorAction SilentlyContinue #powershell
    }
}




# Função para iniciar o projeto Python
function Start-PythonProcess {
    Stop-PythonProcess
    try {
        Start-Sleep -Seconds 10

        $global:pythonProcess = Start-Process powershell -ArgumentList $pyhtonCommand -PassThru -ErrorAction Stop

        Write-Output "Python process started with ID: $($global:pythonProcess.Id)"
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
        
        Stop-NodeProcess
        Stop-PythonProcess

        Write-Host "Removendo arquivos temporários..."
        # Especificar o caminho da pasta
        $pasta =  "$($env:commonPathBot)\venom_bot\tokens"
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
