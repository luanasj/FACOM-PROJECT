import glob
import os

tempFolderPath = r'C:\Users\luana\OneDrive\Documentos\FACOM-Project\Agents\temp\*'

arquivos = glob.glob(tempFolderPath)

for arquivo in arquivos:
    try:
        os.remove(arquivo)
        print(f'{arquivo} foi excluído com sucesso.')
    except Exception as e:
        print(f'Erro ao excluir {arquivo}: {e}')

print(arquivos)




