from dotenv import load_dotenv
load_dotenv()
# #generation prompt "luanasjdev/rag-prompt-with-chat-history"

# ###RETRIEVER

# from dotenv import load_dotenv
# load_dotenv()

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

from langchain_community.document_loaders import PyPDFLoader

# Specify the URL of the PDF
# pdf_url = f"https://facom.ufba.br/portal/conteudo/files/Guia%20do%20semestre%20para%20estudantes%20da%20FACOM%202024-2.pdf"

pdf_url = f"https://facom.ufba.br/portal/conteudo/files/Guia%20do%20semestre%20para%20estudantes%20da%20FACOM%202024-2.pdf"

# Create a loader instance
loader = PyPDFLoader(pdf_url)

# Load the PDF pages
# pages = []
# async for page in loader.alazy_load():
#     pages.append(page)
docs = loader.load()

# Print the content of the first page
print(docs[0].metadata)
print(docs[0])

#Baixar pdfs em pasta do servidor para cnsumir 

# import requests
# from bs4 import BeautifulSoup

# # URL da página que contém os links dos PDFs
# url = 'https://exemplo.com/pagina-com-pdfs'

# # Fazer a requisição para a página
# response = requests.get(url)
# soup = BeautifulSoup(response.content, 'html.parser')

# # Encontrar todos os links de PDF na página
# pdf_links = soup.find_all('a', href=True)
# pdf_links = [link['href'] for link in pdf_links if link['href'].endswith('.pdf')]

# # Baixar cada PDF
# for link in pdf_links:
#     pdf_response = requests.get(link)
#     pdf_name = link.split('/')[-1]
#     with open(pdf_name, 'wb') as pdf_file:
#         pdf_file.write(pdf_response.content)
#     print(f'{pdf_name} baixado com sucesso!')










