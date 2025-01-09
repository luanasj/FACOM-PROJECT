import requests
import os

### Download pdfs
def baixar_pdf(url, pasta_destino, nome_arquivo):
    # Verifica se a pasta de destino existe, se não, cria a pasta
    if not os.path.exists(pasta_destino):
        os.makedirs(pasta_destino)
    
    # Faz o download do PDF
    resposta = requests.get(url, verify=False)
    
    # Caminho completo do arquivo
    caminho_arquivo = os.path.join(pasta_destino, f"{nome_arquivo}")
    
    # Salva o PDF na pasta de destino
    with open(caminho_arquivo, 'wb') as pdf_file:
        pdf_file.write(resposta.content)
    
    print(f"PDF salvo em: {caminho_arquivo}")

### Transform PDF into Docs

import bs4
from langchain_community.document_loaders import WebBaseLoader
from langchain_community.document_loaders import PyPDFLoader

def getDocs(urls,pdflinks,pasta_destino_pdfs):
    # Defina o filtro para incluir apenas a parte específica da página 
    bs4_strainer = bs4.SoupStrainer(class_="pagina-interna")

    # Carregar documentos da web 
    docs = [] 
    for url in urls: 
        loader = WebBaseLoader(web_paths=(url["link"],), bs_kwargs=dict(parse_only=bs4_strainer)) 
        loader.requests_kwargs = {'verify': False} 
        docs.extend(loader.load())


    # Carregar documentos PDF 
    for pdf in pdflinks: 
        loader = PyPDFLoader(os.path.join(pasta_destino_pdfs, pdf["title"] + ".pdf")) 
        docs.extend(loader.load())
    
    return docs

## Exports vectorstore content

def getVectorStoreContent(urls):
    vectorstoreContent = ""

    for url in urls:
        vectorstoreContent += f"""- {url["description"]}\n"""
    
    return vectorstoreContent
