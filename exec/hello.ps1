# # Definir uma ação para ser executada quando Ctrl+C for pressionado
# $action = {
#     Write-Host "Ctrl+C foi pressionado. Encerrando o script..."
#     # Realizar qualquer limpeza necessária aqui
#     exit
# }

# # Registrar o evento de cancelamento do console
# # $null = Register-ObjectEvent -InputObject ([console]::TreatControlCAsInput = $false) -EventName 'CancelKeyPress' -Action $action

# # Registrar o evento de cancelamento do console usando Console.CancelKeyPress
# $null = [Console]::CancelKeyPress.Add([System.ConsoleCancelEventHandler]{
#     param($sender, $eventArgs)
#     $eventArgs.Cancel = $true  # Cancelar a ação padrão para permitir o tratamento personalizado
#     & $action  # Executar a ação definida
# })

# # Loop principal do script
# while ($true) {
#     Write-Host "O script está em execução. Pressione Ctrl+C para interromper."
#     Start-Sleep -Seconds 5
# }

# Definir uma ação a ser executada quando Ctrl+C for pressionado
# $action = {
#     Write-Host "Ctrl+C foi pressionado. Encerrando o script..."
#     # Realizar qualquer limpeza necessária aqui
# }

# # Registrar o evento de cancelamento do console usando [Console]::CancelKeyPress
# $null = [Console]::add_CancelKeyPress({
#     param($sender, $eventArgs)
#     $eventArgs.Cancel = $true  # Cancelar a ação padrão para permitir o tratamento personalizado
#     & $action  # Executar a ação definida
# })

# # Loop principal do script
# while ($true) {
#     Write-Host "O script está em execução. Pressione Ctrl+C para interromper."
#     Start-Sleep -Seconds 5
# }

# function Test-Cmdlet {
#     [CmdletBinding()]
#     param (
#         [Parameter(Mandatory = $true)]
#         [string]$InputString
#     )

#     process {
#         while (-not $PSCmdlet.Stopping) {
#             Write-Output "Processing: $InputString"
#             Start-Sleep -Seconds 1
#         }

#         Write-Output "Cmdlet was stopped."
#     }
# }

# function Trap-CtrlC {
#     ## Stops Ctrl+C from exiting this function
#     [console]::TreatControlCAsInput = $true
#     ## And you have to check every keystroke to see if it's a Ctrl+C
#     ## As far as I can tell, for CtrlC the VirtualKeyCode will be 67 and 
#     ## The ControlKeyState will include either "LeftCtrlPressed" or "RightCtrlPressed" 
#     ## Either of which will -match "CtrlPressed"
#     ## But the simplest thing to do is just compare Character = [char]3
#     if ($Host.UI.RawUI.KeyAvailable -and (3 -eq [int]$Host.UI.RawUI.ReadKey("AllowCtrlC,IncludeKeyUp,NoEcho").Character))
#     {
#        throw (new-object ExecutionEngineException "Ctrl+C Pressed")
#     }
#  }
 
#  function Test-CtrlCIntercept {
#     Trap-CtrlC  # Call Trap-CtrlC right away to turn on TreatControlCAsInput 
#     ## Do your work ...
#     while($true) { 
#        $i = ($i+1)%16
#        Trap-CtrlC ## Constantly check ...
#        write-host (Get-Date) -fore ([ConsoleColor]$i) -NoNewline
#        foreach($sleep in 1..4) {
#           Trap-CtrlC ## Constantly check ...
#           sleep -milli 500; ## Do a few things ...
#           Write-Host "." -fore ([ConsoleColor]$i) -NoNewline
#        }
#        Write-Host
#     }
    
#     trap [ExecutionEngineException] { 
#        Write-Host "Exiting now, don't try to stop me...." -Background DarkRed
#        continue # Be careful to do the right thing here (or just don't do anything)
#     }
#  }

# # Example usage
# Test-Cmdlet -InputString "Hello World"

# Change the default behavior of CTRL-C so that the script can intercept and use it versus just terminating the script.
# [Console]::TreatControlCAsInput = $True
# # Sleep for 1 second and then flush the key buffer so any previously pressed keys are discarded and the loop can monitor for the use of
# #   CTRL-C. The sleep command ensures the buffer flushes correctly.
# Start-Sleep -Seconds 1
# $Host.UI.RawUI.FlushInputBuffer()

# # Continue to loop while there are pending or currently executing jobs.
# While ($true) {
#     # If a key was pressed during the loop execution, check to see if it was CTRL-C (aka "3"), and if so exit the script after clearing
#     #   out any running jobs and setting CTRL-C back to normal.
#     If ($Host.UI.RawUI.KeyAvailable -and ($Key = $Host.UI.RawUI.ReadKey("AllowCtrlC,NoEcho,IncludeKeyUp"))) {
#         If ([Int]$Key.Character -eq 3) {
#             Write-Host ""
#             Write-Warning "CTRL-C was used - Shutting down any running jobs before exiting the script."
#             Get-Job | Where-Object {$_.Name -like "MessageProfile*"} | Remove-Job -Force -Confirm:$False
#             [Console]::TreatControlCAsInput = $False
#             _Exit-Script -HardExit $True
#         }
#         # Flush the key buffer again for the next loop.
#         $Host.UI.RawUI.FlushInputBuffer()
        
#     }
#     Start-Sleep -Seconds 5
#     # Perform other work here such as process pending jobs or process out current jobs.
# }

# Register engine event for PowerShell exiting
# Register-EngineEvent -SourceIdentifier PowerShell.Exiting -Action {
#     Write-Host "PowerShell is exiting."
# }

# # Register console cancel event
# Register-ObjectEvent -InputObject [console]::CancelKeyPress -EventName 'CancelKeyPress' -Action {
#     Write-Host "Console cancel event detected. Exiting gracefully..."
#     $eventArgs.Cancel = $true  # Prevents the default behavior of terminating the script
# }

# # Keep the script running to listen for events
# while ($true) {
#     Start-Sleep -Seconds 1
# }

# Definir uma ação a ser executada quando Ctrl+C for pressionado
# $action = {
#     Write-Host "Ctrl+C foi pressionado. Encerrando o script..."
#     # Realizar qualquer limpeza necessária aqui
#     exit
# }

# # Registrar o evento de cancelamento do console usando [Console]::CancelKeyPress
# $null = [Console]::add_CancelKeyPress({
#     param($sender, $eventArgs)
#     $eventArgs.Cancel = $true  # Cancelar a ação padrão para permitir o tratamento personalizado
#     & $action  # Executar a ação definida
# })

# # Loop principal do script
# while ($true) {
#     Write-Host "O script está em execução. Pressione Ctrl+C para interromper."
#     Start-Sleep -Seconds 5
# }

# trap {
#     Write-Host "Script interrompido. Executando ação final..."
#     # Coloque aqui o código que deve ser executado ao final
#     exit
# }

# # Código principal do script
# Write-Host "Executando o script..."
# Start-Sleep -Seconds 10  # Simula uma operação demorada

# # Ação final (opcional, caso o script termine normalmente)
# Write-Host "Script concluído com sucesso."

# [Console]::CancelKeyPress = {
#     Write-Host "Script interrompido. Executando ação final..."
#     # Coloque aqui o código que deve ser executado ao final
# }

# # Código principal do script
# Write-Host "Executando o script..."
# try {
#     Start-Sleep -Seconds 10  # Simula uma operação demorada
# }
# finally {
#     # Ação final que será executada mesmo após interrupção
#     Write-Host "Executando ação final..."
#     # Coloque aqui o código que deve ser executado ao final
# }

# [Console]::TreatControlCAsInput = $false  # Garante que Ctrl+C encerre o script
# [Console]::CancelKeyPress.AddHandler({
#     param($sender, $eventArgs)
#     Write-Host "Script interrompido. Executando ação final..."
#     # Coloque aqui o código que deve ser executado ao final
#     $eventArgs.Cancel = $true  # Opcional: impede o encerramento imediato do script
# })

# # Código principal do script
# Write-Host "Executando o script..."
# try {
#     Start-Sleep -Seconds 10  # Simula uma operação demorada
# }
# finally {
#     # Ação final que será executada mesmo após interrupção
#     Write-Host "Executando ação final..."
#     # Coloque aqui o código que deve ser executado ao final
# }

# Registra o manipulador de eventos para CTRL+C (SIGINT)
# $eventAction = {
#     Write-Host "`nIniciando operações de limpeza..."
    
#     # Exemplo de operações de limpeza
#     try {
#         # Limpar arquivos temporários
#         Write-Host "Removendo arquivos temporários..."
        
#         # Fechar conexões de rede
#         Write-Host "Fechando conexões de rede..."
        
#         # Liberar recursos do sistema
#         Write-Host "Liberando recursos..."
        
#     }
#     catch {
#         Write-Host "Erro durante a limpeza: $_" -ForegroundColor Red
#     }
#     finally {
#         Write-Host "Operações de limpeza concluídas" -ForegroundColor Green
#     }
# }

# # Registra o manipulador para CTRL+C
# $null = Register-EngineEvent -SourceIdentifier PowerShell.Exiting -Action $eventAction

# # Registra também para quando o script terminar normalmente
# $null = Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -Action $eventAction

# # Seu código principal aqui
# try {
#     Write-Host "Script iniciado. Pressione CTRL+C para encerrar..."
#     while ($true) {
#         # Simulação de trabalho
#         Start-Sleep -Seconds 1
#     }
# }
# finally {
#     # Remover os manipuladores de eventos ao finalizar
#     Unregister-Event -SourceIdentifier PowerShell.Exiting
#     Unregister-Event -SourceIdentifier PowerShell.OnIdle
# }

# Função que será chamada na limpeza
# function Cleanup {
#     Write-Host "`nIniciando operações de limpeza..."
    
#     try {
#         # Coloque aqui suas operações de limpeza
#         Write-Host "Removendo arquivos temporários..."
#         Write-Host "Fechando conexões..."
#         Write-Host "Liberando recursos..."
#     }
#     catch {
#         Write-Host "Erro durante a limpeza: $_" -ForegroundColor Red
#     }
#     finally {
#         Write-Host "Operações de limpeza concluídas" -ForegroundColor Green
#     }
# }

# # Configura o manipulador de CTRL+C
# [Console]::TreatControlCAsInput = $false
# $PSDefaultParameterValues['*:ErrorAction'] = 'Stop'

# try {
#     Write-Host "Script iniciado. Pressione CTRL+C para encerrar..."
    
#     # Registra o manipulador de CTRL+C
#     $null = [Console]::CancelKeyPress.Register({
#         param($sender, $e)
#         $e.Cancel = $true  # Impede o encerramento imediato
#         Write-Host "`nCTRL+C detectado!"
#         throw "Script interrompido pelo usuário"
#     })
    
#     # Seu código principal aqui
#     while ($true) {
#         # Simulação de trabalho
#         Start-Sleep -Seconds 1
#         Write-Host "." -NoNewline
#     }
# }
# catch {
#     if ($_.Exception.Message -ne "Script interrompido pelo usuário") {
#         Write-Host "`nErro não esperado: $_" -ForegroundColor Red
#     }
# }
# finally {
#     # Esta parte SEMPRE será executada, mesmo com CTRL+C
#     Cleanup
# }

# Função que será chamada na limpeza
function Cleanup {
    Write-Host "`nIniciando operações de limpeza..."
    
    try {
        # Coloque aqui suas operações de limpeza
        Write-Host "Removendo arquivos temporários..."
        Write-Host "Fechando conexões..."
        Write-Host "Liberando recursos..."
    }
    catch {
        Write-Host "Erro durante a limpeza: $_" -ForegroundColor Red
    }
    finally {
        Write-Host "Operações de limpeza concluídas" -ForegroundColor Green
    }
}

# Registra o manipulador de CTRL+C usando o método nativo do PowerShell
$null = Register-ObjectEvent -InputObject ([System.Management.Automation.RunspaceConfiguration]::DefaultRunspace.InitialSessionState) -EventName Exit -Action {
    Write-Host "`nCTRL+C detectado!"
    Cleanup
}

try {
    Write-Host "Script iniciado. Pressione CTRL+C para encerrar..."
    
    # Seu código principal aqui
    while ($true) {
        # Simulação de trabalho
        Start-Sleep -Seconds 1
        Write-Host "." -NoNewline
    }
}
catch {
    Write-Host "`nErro não esperado: $_" -ForegroundColor Red
}
finally {
    # Esta parte SEMPRE será executada, mesmo com CTRL+C
    Cleanup
    # Limpa o evento registrado
    Get-EventSubscriber | Unregister-Event
}