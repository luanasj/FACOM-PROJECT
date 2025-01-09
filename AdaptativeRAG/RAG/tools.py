from dotenv import load_dotenv
load_dotenv()

from RAG.utils import baixar_pdf,getDocs,getVectorStoreContent

# PDFs to index

pdflinks = [{"link":f"https://facom.ufba.br/portal/conteudo/files/EDITAL%20PROEXT%202024.pdf","title":"pdf1"},{"link":f"https://facom.ufba.br/portal/conteudo/files/Guia%20do%20semestre%20para%20estudantes%20da%20FACOM%202024-2.pdf","title":"pdf2"}]

pasta_destino_pdfs = r'C:\Users\luana\OneDrive\Documentos\FACOM-Project\Agents\temp'

for item in pdflinks:
    baixar_pdf(item["link"], pasta_destino_pdfs, item["title"]+".pdf")

#URLs to index

urls = [{"link":"https://facom.ufba.br/portal/informes/787/confira-resultado-final-da-selecao-para-estagio-remunerado-na-facom-ufba","description":"resultado para a selecao de estagio remunerado;"},{"link":"https://facom.ufba.br/portal/pagina/47/","description":"orientações sobre estágio,atividades complementares,atestado medico (abono de falta),trancamento de disciplinas, salvador card e inscrição em componentes de outros cursos;"},{"link":"https://facom.ufba.br/portal/informes/777/departamento-de-comunicacao-abre-inscricoes-para-selecao-de-monitores", "description":"incricoes para selecao de monitores"}]

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

retriever = vectorstore.as_retriever()

# Get vectorstoreContent

vectorstoreContent = getVectorStoreContent(urls)

from langchain_community.tools.tavily_search import TavilySearchResults

web_search_tool = TavilySearchResults(
    max_results=3,
    search_depth="advanced",
    include_answer=True,
    include_raw_content=True,
    include_images=True,
    include_domains=["facom.ufba.br"]
)