from dotenv import load_dotenv
load_dotenv()
import os
import json

from RAG.utils import baixar_pdf,getDocs,getVectorStoreContent

# PDFs to index

with open(os.getenv("commonPathBot")+"\\externalLinks.json") as file:
    externalLinks = json.load(file)



pdflinks = externalLinks["pdfs"]

pasta_destino_pdfs = os.getenv("commonPathBot")+"\\temp"

for item in pdflinks:
    baixar_pdf(item["link"], pasta_destino_pdfs, item["title"]+".pdf")

#URLs to index

urls = externalLinks["web"]

### Build Index

from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_community.vectorstores import Chroma
from langchain_cohere import CohereEmbeddings


# Set embeddings
embd = CohereEmbeddings(model='embed-english-v3.0')

#docs
docs = getDocs(urls,pdflinks,pasta_destino_pdfs)


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

retriever = vectorstore.as_retriever(
    search_kwargs={'k': 7}
)

# Get vectorstoreContent

vectorstoreContent = getVectorStoreContent(urls)

from langchain_community.tools.tavily_search import TavilySearchResults

web_search_tool = TavilySearchResults(
    max_results=5,
    search_depth="advanced",
    include_answer=True,
    include_raw_content=True,
    include_images=True,
    include_domains=["facom.ufba.br"]
)