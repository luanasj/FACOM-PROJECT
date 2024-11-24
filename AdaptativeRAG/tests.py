from dotenv import load_dotenv
load_dotenv()
# #generation prompt "luanasjdev/rag-prompt-with-chat-history"

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

# PDFs to index

pdflinks = [{"link":f"https://facom.ufba.br/portal/conteudo/files/EDITAL%20PROEXT%202024.pdf","title":"pdf1"},{"link":f"https://facom.ufba.br/portal/conteudo/files/Guia%20do%20semestre%20para%20estudantes%20da%20FACOM%202024-2.pdf","title":"pdf2"}]

pasta_destino_pdfs = r'C:\Users\luana\OneDrive\Documentos\FACOM-Project\Agents\temp'
#pdf_paths = []


for item in pdflinks:
    baixar_pdf(item["link"], pasta_destino_pdfs, item["title"]+".pdf")
#    pdf_paths.append("../temp/" + item["title"] +  ".pdf")


# Web pages to index
urls = [
    "https://facom.ufba.br/portal/informes/787/confira-resultado-final-da-selecao-para-estagio-remunerado-na-facom-ufba",
    "https://facom.ufba.br/portal/informes/783/facom-recebe-novos-estudantes-com-programacao-de-acolhimento-",
    "https://facom.ufba.br/portal/informes/777/departamento-de-comunicacao-abre-inscricoes-para-selecao-de-monitores",
]

### Build Index
import bs4
from langchain import hub
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_community.document_loaders import WebBaseLoader
from langchain_community.vectorstores import Chroma

from langchain_groq import ChatGroq
from langchain_core.output_parsers import StrOutputParser
# from langchain_core.runnables import RunnablePassthrough

# from langchain_openai import OpenAIEmbeddings

from langchain_cohere import CohereEmbeddings
from langchain_community.document_loaders import PyPDFLoader


llm = ChatGroq(model="llama3-8b-8192")

# Set embeddings
embd = CohereEmbeddings(model='embed-english-v3.0')


#docs
# Defina o filtro para incluir apenas a parte específica da página 
bs4_strainer = bs4.SoupStrainer(class_="pagina-interna")


# Carregar documentos da web 
docs = [] 
for url in urls: 
    loader = WebBaseLoader(web_paths=(url,), bs_kwargs=dict(parse_only=bs4_strainer)) 
    loader.requests_kwargs = {'verify': False} 
    docs.extend(loader.load())

# Carregar documentos PDF 
for pdf in pdflinks: 
    loader = PyPDFLoader(os.path.join(pasta_destino_pdfs, pdf["title"] + ".pdf")) 
    docs.extend(loader.load())


# Split
text_splitter = RecursiveCharacterTextSplitter.from_tiktoken_encoder(
    chunk_size=300, chunk_overlap=20
)
doc_splits = text_splitter.split_documents(docs)

# Add to vectorstore
vectorstore = Chroma.from_documents(
    documents=doc_splits,
    collection_name="rag-chroma",
    embedding=embd,
)
retriever = vectorstore.as_retriever()


prompt = hub.pull("rlm/rag-prompt")

question = "O departamento de comunicacao abriu inscricao para monitores?"


# def format_docs(docs):
#     return "\n\n".join(doc.page_content for doc in docs)

context = retriever.invoke(question)


rag_chain = prompt | llm | StrOutputParser()


# Run
generation = rag_chain.invoke({"context": context, "question": question})
print(generation)










# Exemplo de uso
# url_pdf = f"https://facom.ufba.br/portal/conteudo/files/Guia%20do%20semestre%20para%20estudantes%20da%20FACOM%202024-2.pdf"
# pasta_destino = r'C:\Users\luana\OneDrive\Documentos\FACOM-Project\Agents\temp'
# nome_arquivo = 'arquivoSiteFacom'



# baixar_pdf(url_pdf, pasta_destino, nome_arquivo)



### Download pdfs

# ### Build Index

# from langchain.text_splitter import RecursiveCharacterTextSplitter
# from langchain_community.document_loaders import WebBaseLoader
# from langchain_community.vectorstores import Chroma
# # from langchain_openai import OpenAIEmbeddings

# from langchain_cohere import CohereEmbeddings

# # Set embeddings
# embd = CohereEmbeddings(model='embed-english-v3.0')

# # Docs to index
# urls = [
#     "https://lilianweng.github.io/posts/2023-06-23-agent/",
#     "https://lilianweng.github.io/posts/2023-03-15-prompt-engineering/",
#     "https://lilianweng.github.io/posts/2023-10-25-adv-attack-llm/",
# ]

# #PDF to index

# #docs
# docs = [WebBaseLoader(url).load() for url in urls]

# # Load
# docs_list = [item for sublist in docs for item in sublist]

# # Split
# text_splitter = RecursiveCharacterTextSplitter.from_tiktoken_encoder(
#     chunk_size=500, chunk_overlap=0
# )
# doc_splits = text_splitter.split_documents(docs_list)

# # Add to vectorstore
# vectorstore = Chroma.from_documents(
#     documents=doc_splits,
#     collection_name="rag-chroma",
#     embedding=embd,
# )
# retriever = vectorstore.as_retriever()

# from langchain_community.document_loaders import UnstructuredPDFLoader
# from langchain_community.document_loaders.pdf import OnlinePDFLoader

# file_path = "../Uso_da_inteligencia_artificial_na_educacao.pdf"
# loader = UnstructuredPDFLoader(file_path)


# loader = OnlinePDFLoader("https://arxiv.org/pdf/2302.03803.pdf")


# docs = loader.load()
# docs[0]

# print(docs[0].metadata)

# from langchain_community.document_loaders import PyPDFLoader

# # Specify the URL of the PDF
# # pdf_url = f"https://facom.ufba.br/portal/conteudo/files/Guia%20do%20semestre%20para%20estudantes%20da%20FACOM%202024-2.pdf"

# pdf_url = f"../temp/{nome_arquivo}.pdf"

# # Create a loader instance
# loader = PyPDFLoader(pdf_url)

# # Load the PDF pages
# # pages = []
# # async for page in loader.alazy_load():
# #     pages.append(page)
# docs = loader.load()

# # Print the content of the first page
# print(docs[1].metadata)
# print(docs[1])

# #Baixar pdfs em pasta do servidor para cnsumir 

# # import requests
# # from bs4 import BeautifulSoup

# # # URL da página que contém os links dos PDFs
# # url = 'https://exemplo.com/pagina-com-pdfs'

# # # Fazer a requisição para a página
# # response = requests.get(url)
# # soup = BeautifulSoup(response.content, 'html.parser')

# # # Encontrar todos os links de PDF na página
# # pdf_links = soup.find_all('a', href=True)
# # pdf_links = [link['href'] for link in pdf_links if link['href'].endswith('.pdf')]

# # # Baixar cada PDF
# # for link in pdf_links:
# #     pdf_response = requests.get(link)
# #     pdf_name = link.split('/')[-1]
# #     with open(pdf_name, 'wb') as pdf_file:
# #         pdf_file.write(pdf_response.content)
# #     print(f'{pdf_name} baixado com sucesso!')










