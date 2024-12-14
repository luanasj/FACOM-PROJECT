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
# urls = [
#     "https://facom.ufba.br/portal/informes/787/confira-resultado-final-da-selecao-para-estagio-remunerado-na-facom-ufba",
#     "https://facom.ufba.br/portal/pagina/47/",
#     "https://facom.ufba.br/portal/informes/777/departamento-de-comunicacao-abre-inscricoes-para-selecao-de-monitores",
# ]

urls = [{"link":"https://facom.ufba.br/portal/informes/787/confira-resultado-final-da-selecao-para-estagio-remunerado-na-facom-ufba","description":"resultado para a selecao de estagio remunerado;"},{"link":"https://facom.ufba.br/portal/pagina/47/","description":"orientações sobre estágio,atividades complementares,atestado medico (abono de falta),trancamento de disciplinas, salvador card e inscrição em componentes de outros cursos;"},{"link":"https://facom.ufba.br/portal/informes/777/departamento-de-comunicacao-abre-inscricoes-para-selecao-de-monitores", "description":"incricoes para selecao de monitores"}]

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


llm = ChatGroq(model="llama3-8b-8192",temperature=0)

# Set embeddings
embd = CohereEmbeddings(model='embed-english-v3.0')


#docs
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

### Router

from typing import Literal

from langchain_core.prompts import ChatPromptTemplate
# from langchain_groq import ChatGroq

from pydantic import BaseModel, Field

## Route Query

class rag_or_generate(BaseModel):
    """
    Invokes the agent model to generate a response based on the current state. Given
    the question, it will decide to route retrieve using the retriever tool, or simply generate.

    """

    method: Literal["generate","retrieve"] = Field(
        ...,
        description="Given a user question choose to send it to generate or retrieve.",
    )

# LLM with function call
# llm = ChatGroq(model="llama3-8b-8192",temperature=0)
structured_llm_decision_maker = llm.with_structured_output(rag_or_generate)

# Prompt

system = """You are an expert at determining whether to retrieve information from a database or generate an answer based on a user message.

If the question is related to FACOM (Faculdade de Comunicação UFBA), including topics such as college/university, enrollment, grades, or any other university-related context, you should retrieve the information from the database.

For all other questions, you should generate an answer without additional context.

Your goal is to provide accurate and relevant responses based on the user's query.
""" 
# system = """You are an expert at deciding, based on a user message, to retrieve or generate an answer.
#   To retrieve is needed for questions related to FACOM(Faculdade de Comunicação UFBA), about college/university, 
#   enrolment, grades. Otherwise call generate.
#  """ 


agent_prompt = ChatPromptTemplate.from_messages(
    [
        ("system", system),
        ("user", "{question}"),
    ]
)

agent_router = agent_prompt | structured_llm_decision_maker

# Data model
class RouteQuery(BaseModel):
    """Route a user query to the most relevant datasource."""

    datasource: Literal["vectorstore", "web_search"] = Field(
        ...,
        description="Given a user question choose to route it to web search or a vectorstore.",
    )


# LLM with function call
# llm = ChatGroq(model="llama3-8b-8192",temperature=0)
structured_llm_router = llm.with_structured_output(RouteQuery)

#VectorStore content description

vectorstoreContent = ""

for url in urls:
    vectorstoreContent += f"""- {url["description"]}\n"""


# Prompt
system = f"""You are an expert at determining whether to retrieve information from a vectorstore or perform a web search based on a user's question.

The vectorstore contains documents related to the following topics:
{vectorstoreContent}.

Use the vectorstore for questions on these topics.

For all other questions, including those not explicitly mentioned or when the information is not found in the vectorstore, use web search. 

Examples: 
1. "Como faço para tirar/abonar uma falta?" -> Use vectorstore 
2. "Como eu faço meu salvadorcard?" -> Use vectorstore 
3. "Quais sao os professores da facom?" -> Use web search 
4. "Como faço para trocar de curso?" -> Use web search

Your goal is to provide accurate and relevant responses based on the user's query."""

# system = f"""You are an expert at routing a user question to a vectorstore or web search.
# The vectorstore contains documents related to {vectorstoreContent}.
# Use the vectorstore for questions on these topics. Otherwise, use web-search."""

route_prompt = ChatPromptTemplate.from_messages(
    [
        ("system", system),
        ("human", "{question}"),
    ]
)

question_router = route_prompt | structured_llm_router

### Retrieval Grader


# Data model
class GradeDocuments(BaseModel):
    """Binary score for relevance check on retrieved documents."""

    binary_score: str = Field(
        description="Documents are relevant to the question, 'yes' or 'no'"
    )


# LLM with function call
# llm = ChatOpenAI(model="gpt-3.5-turbo-0125", temperature=0)
structured_llm_grader = llm.with_structured_output(GradeDocuments)

# Prompt
system = """You are a grader assessing relevance of a retrieved document to a user question. \n 
    If the document contains keyword(s) or semantic meaning related to the user question, grade it as relevant. \n
    It does not need to be a stringent test. The goal is to filter out erroneous retrievals. \n
    Give a binary score 'yes' or 'no' score to indicate whether the document is relevant to the question."""
grade_prompt = ChatPromptTemplate.from_messages(
    [
        ("system", system),
        ("human", "Retrieved document: \n\n {document} \n\n User question: {question}"),
    ]
)

retrieval_grader = grade_prompt | structured_llm_grader

### Generate

from langchain import hub
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_core.output_parsers import StrOutputParser


#RAG generate
# Prompt
rag_prompt = hub.pull("luanasjdev/rag-prompt-with-chat-history")


# Chain
rag_chain = rag_prompt | llm | StrOutputParser()


#NoRAG Generation
import json

def getSelectorsFromJSON(jsonPath):
    with open(jsonPath, 'r',encoding='utf-8') as arquivo:
        dadosJSON = json.load(arquivo)

    selectors = ""

    for i in range(len(dadosJSON)):
        item = dadosJSON[i]
        selectors += f"{i+1} {item['name']}\n"

    # selectors += f"{len(dadosJSON)+1} Outros" 

    return selectors

llm = ChatGroq(model="llama3-8b-8192",temperature=0)

no_rag_prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            f'''Você é um assistente preparado para responder informacoes sobre a FACOM (Faculdade de Comunicação) da UFBA. Se a pergunta nao for relacionada à FACOM ou ao contexto universitário diga que não pode responder.

            Caso seja a primeira mensagem do usuário ou uma saudação como "olá", "bom dia", "você pode me ajudar","tenho uma dúvida", peça que o usuário escolha uma das opcções do menu abaixo digitando o número da opção desejada. 

            
            {getSelectorsFromJSON('../externalInfo.json')}
            
            Caso não seja nenhuma das opções acima, o usuário deve digitar a sua pergunta.
            ''',
        ),
        MessagesPlaceholder(variable_name="messages"),
    ]
)

# Chain
no_rag_chain = no_rag_prompt | llm | StrOutputParser()



### Hallucination Grader


# Data model
class GradeHallucinations(BaseModel):
    """Binary score for hallucination present in generation answer."""

    binary_score: str = Field(
        description="Answer is grounded in the facts, 'yes' or 'no'"
    )


# LLM with function call
# llm = ChatOpenAI(model="gpt-3.5-turbo-0125", temperature=0)
structured_llm_grader = llm.with_structured_output(GradeHallucinations)

# Prompt
system = """You are a grader assessing whether an LLM generation is grounded in / supported by a set of retrieved facts. \n 
     Give a binary score 'yes' or 'no'. 'Yes' means that the answer is grounded in / supported by the set of facts."""
hallucination_prompt = ChatPromptTemplate.from_messages(
    [
        ("system", system),
        ("human", "Set of facts: \n\n {documents} \n\n LLM generation: {generation}"),
    ]
)

hallucination_grader = hallucination_prompt | structured_llm_grader

### Answer Grader


# Data model
class GradeAnswer(BaseModel):
    """Binary score to assess answer addresses question."""

    binary_score: str = Field(
        description="Answer addresses the question, 'yes' or 'no'"
    )


# LLM with function call
# llm = ChatOpenAI(model="gpt-3.5-turbo-0125", temperature=0)
structured_llm_grader = llm.with_structured_output(GradeAnswer)

# Prompt
system = """You are a grader assessing whether an answer addresses / resolves a question \n 
     Give a binary score 'yes' or 'no'. Yes' means that the answer resolves the question."""
answer_prompt = ChatPromptTemplate.from_messages(
    [
        ("system", system),
        ("human", "User question: \n\n {question} \n\n LLM generation: {generation}"),
    ]
)

answer_grader = answer_prompt | structured_llm_grader

### Question Re-writer

# LLM
# llm = ChatOpenAI(model="gpt-3.5-turbo-0125", temperature=0)

# Prompt
system = """You a question re-writer that converts an input question to a better version that is optimized \n 
     for vectorstore retrieval. Look at the input and try to reason about the underlying semantic intent / meaning."""
re_write_prompt = ChatPromptTemplate.from_messages(
    [
        ("system", system),
        (
            "human",
            "Here is the initial question: \n\n {question} \n Formulate an improved question.",
        ),
    ]
)

question_rewriter = re_write_prompt | llm | StrOutputParser()


### Search

from langchain_community.tools.tavily_search import TavilySearchResults

# web_search_tool = TavilySearchResults(k=3)

web_search_tool = TavilySearchResults(
    max_results=3,
    search_depth="advanced",
    include_answer=True,
    include_raw_content=True,
    include_images=True,
    include_domains=["facom.ufba.br"]
    # include_domains=["facom.ufba.br","portal.ufba.br","supac.ufba.br","supac.ufba.br"],
    # exclude_domains=[...],
    # name="...",            # overwrite default tool name
    # description="...",     # overwrite default tool description
    # args_schema=...,       # overwrite default args_schema: BaseModel
)

### Construct the graph

##Define the graph state

from typing import List,Annotated

from typing_extensions import TypedDict

from langgraph.graph.message import add_messages


class GraphState(TypedDict):
    """
    Represents the state of our graph.

    Attributes:
        question: question
        messages: chat_history
        generation: LLM generation
        documents: list of documents
    """
    question: List[list]
    messages: Annotated[list, add_messages]
    generation: str
    documents: List[str]

##Define Graph Flow

from langchain.schema import Document
from langchain_core.messages import BaseMessage, HumanMessage,AIMessage,SystemMessage


def retrieve(state):
    """
    Retrieve documents

    Args:
        state (dict): The current graph state

    Returns:
        state (dict): New key added to state, documents, that contains retrieved documents
    """
    print("---RETRIEVE---")

    question = state["question"][-1].content
    

    # Retrieval
    documents = retriever.invoke(question)
    return {"documents": documents, "question": [HumanMessage(content=f"{question}")]}

def generate(state):
    """
    Generate answer

    Args:
        state (dict): The current graph state

    Returns:
        state (dict): New key added to state, generation, that contains LLM generation
    """
    print("---GENERATE---")
    question = state["question"][-1]
    question = question.content
    documents = state["documents"]
    historyEnd = len(state["messages"]) - 1
    history = state["messages"][historyEnd-4:historyEnd]
    
    

    # RAG generation
    generation = rag_chain.invoke({"context": documents, "question": question,"history":history})
    return {"documents": documents, "question": [HumanMessage(content=f"{question}")], "generation": generation, "messages":[HumanMessage(content=f"{question}"),AIMessage(content=f"{generation}")]}

def generate_without_rag(state):
    """
    Generate answer

    Args:
        state (dict): The current graph state

    Returns:
        state (dict): New key added to state, generation, that contains LLM generation
    """
    print("---GENERATE---")
    question = state["question"][-1]
    documents = ""
    historyEnd = len(state["messages"]) - 1
    history = state["messages"][historyEnd-4:historyEnd]
    
    

    # RAG generation
    generation = no_rag_chain.invoke({"messages": history+[question]})
    return {"documents": documents, "question": [HumanMessage(content=f"{question}")], "generation": generation, "messages":[HumanMessage(content=f"{question}"),AIMessage(content=f"{generation}")]}



def grade_documents(state):
    """
    Determines whether the retrieved documents are relevant to the question.

    Args:
        state (dict): The current graph state

    Returns:
        state (dict): Updates documents key with only filtered relevant documents
    """

    print("---CHECK DOCUMENT RELEVANCE TO QUESTION---")
    question = state["question"][-1]
    question = question.content    
    documents = state["documents"]

    # Score each doc
    filtered_docs = []
    for d in documents:
        score = retrieval_grader.invoke(
            {"question": question, "document": d.page_content}
        )
        grade = score.binary_score
        if grade == "yes":
            print("---GRADE: DOCUMENT RELEVANT---")
            filtered_docs.append(d)
        else:
            print("---GRADE: DOCUMENT NOT RELEVANT---")
            continue
    return {"documents": filtered_docs, "question": [HumanMessage(content=f"{question}")]}


def transform_query(state):
    """
    Transform the query to produce a better question.

    Args:
        state (dict): The current graph state

    Returns:
        state (dict): Updates question key with a re-phrased question
    """

    print("---TRANSFORM QUERY---")
    question = state["question"][-1]
    question = question.content
    documents = state["documents"]

    # Re-write question
    better_question = question_rewriter.invoke({"question": question})
    return {"documents": documents, "question": [HumanMessage(content=f"{better_question}")]}

def web_search(state):
    """
    Web search based on the re-phrased question.

    Args:
        state (dict): The current graph state

    Returns:
        state (dict): Updates documents key with appended web results
    """

    print("---WEB SEARCH---")
    question = state["question"][-1]
    question = question.content

    # Web search
    docs = web_search_tool.invoke({"query": question})
    web_results = "\n".join([d["content"] for d in docs])
    web_results = Document(page_content=web_results)

    return {"documents": web_results, "question": [HumanMessage(content=f"{question}")]}



def route_question(state):
    """
    Route question to web search or RAG.

    Args:
        state (dict): The current graph state

    Returns:
        str: Next node to call
    """

    print("---ROUTE QUESTION---")
    question = state["question"][-1]
    question = question.content
    source = question_router.invoke({"question": question})
    try:
        decision =  agent_router.invoke({"question": question})
    except Exception:
        decision = AIMessage(content='content',method='generate')
    if decision.method == "generate":
        print("---ROUTE QUESTION TO GENERATE---")
        return "generate"
    elif decision.method == "retrieve":
        source = question_router.invoke({"question": question})
        if source.datasource == "web_search":
            print("---ROUTE QUESTION TO WEB SEARCH---")
            return "web_search"
        elif source.datasource == "vectorstore":
            print("---ROUTE QUESTION TO RAG---")
            return "vectorstore"

    # source = question_router.invoke({"question": question})
    # if source.datasource == "web_search":
    #     print("---ROUTE QUESTION TO WEB SEARCH---")
    #     return "web_search"
    # elif source.datasource == "vectorstore":
    #     print("---ROUTE QUESTION TO RAG---")
    #     return "vectorstore"


def decide_to_generate(state):
    """
    Determines whether to generate an answer, or re-generate a question.

    Args:
        state (dict): The current graph state

    Returns:
        str: Binary decision for next node to call
    """

    print("---ASSESS GRADED DOCUMENTS---")
    state["question"][-1].content
    filtered_documents = state["documents"]

    if not filtered_documents:
        # All documents have been filtered check_relevance
        # We will re-generate a new query
        print(
            "---DECISION: ALL DOCUMENTS ARE NOT RELEVANT TO QUESTION, TRANSFORM QUERY---"
        )
        return "transform_query"
    else:
        # We have relevant documents, so generate answer
        print("---DECISION: GENERATE---")
        return "generate"


def grade_generation_v_documents_and_question(state):
    """
    Determines whether the generation is grounded in the document and answers question.

    Args:
        state (dict): The current graph state

    Returns:
        str: Decision for next node to call
    """

    print("---CHECK HALLUCINATIONS---")
    question = state["question"][-1]
    question = question.content
    documents = state["documents"]
    generation = state["generation"]

    score = hallucination_grader.invoke(
        {"documents": documents, "generation": generation}
    )
    grade = score.binary_score

    # Check hallucination
    if grade == "yes":
        print("---DECISION: GENERATION IS GROUNDED IN DOCUMENTS---")
        # Check question-answering
        print("---GRADE GENERATION vs QUESTION---")
        score = answer_grader.invoke({"question": question, "generation": generation})
        grade = score.binary_score
        if grade == "yes":
            print("---DECISION: GENERATION ADDRESSES QUESTION---")
            return "useful"
        else:
            print("---DECISION: GENERATION DOES NOT ADDRESS QUESTION---")
            return "not useful"
    else:
        print("---DECISION: GENERATION IS NOT GROUNDED IN DOCUMENTS, RE-TRY---")
        return "not supported"


from langgraph.graph import END, StateGraph, START

workflow = StateGraph(GraphState)

# Define the nodes
workflow.add_node("web_search", web_search)  # web search
workflow.add_node("retrieve", retrieve)  # retrieve
workflow.add_node("grade_documents", grade_documents)  # grade documents
workflow.add_node("generate", generate)  # generatae
workflow.add_node("transform_query", transform_query)  # transform_query
workflow.add_node("generate_without_rag", generate_without_rag) # route to rag or retrieve

# Build graph

workflow.add_conditional_edges(
    START,
    route_question,
    {
        "generate":"generate_without_rag",
        "web_search": "web_search",
        "vectorstore": "retrieve",
    },
)

# workflow.add_conditional_edges(
#     START,
#     route_question,
#     {
#         "web_search": "web_search",
#         "vectorstore": "retrieve",
#     },
# )

workflow.add_edge("generate_without_rag",END)
workflow.add_edge("web_search", "generate")
workflow.add_edge("retrieve", "grade_documents")
workflow.add_conditional_edges(
    "grade_documents",
    decide_to_generate,
    {
        "transform_query": "transform_query",
        "generate": "generate",
    },
)
workflow.add_edge("transform_query", "retrieve")
# workflow.add_conditional_edges(
#     "generate",
#     grade_generation_v_documents_and_question,
#     {
#         "not supported": "generate",
#         "useful": END,
#         "not useful": "transform_query",
#     },
# )

workflow.add_edge("generate",END)


#Persistence
from langgraph.checkpoint.memory import MemorySaver

memory = MemorySaver()


# Compile
compiled_workflow = workflow.compile(checkpointer=memory)


# from pprint import pprint

# Run

def getAIAnswer(question,user_id,thread_id):
    config = {"configurable": {"user_id":user_id,"thread_id": thread_id}}
    input_message = HumanMessage(content=question)


    AIanswer = compiled_workflow.invoke({"question": [input_message]}, config, stream_mode="values")
    AIanswerContent = AIanswer["messages"][-1].content
    
    return AIanswerContent

# systemActive = True

# def systemActivation():
#     global systemActive
#     systemActive = not systemActive

# def callMessages():
#     global systemActive
#     while systemActive:
#         userQuestion = input("Digite uma pergunta: ")
#         userID= input("id: ")

#         try:
#             print(f"resposta: {getAIAnswer(userQuestion,userID)}")  
#         except Exception:
#             print("tive um problema processando a sua pergunta. Por favor, tente novamente.")

       

#         keepActive = input("Do you want to keep the System Active?(y/n): ")
#         if keepActive == "n": 
#             systemActivation()


# callMessages()

from flask import Flask,request
from markupsafe import escape

app = Flask(__name__)

@app.route("/")
def hello_world():
    return "<p>Hello, World!</p>"



# @app.route("/<name>")
# def hello(name):
#     return f"Hello, {escape(name)}!"


@app.route("/aimessage/<messageid>",methods=["POST"])
def hello(messageid):
    # print(escape(request.get_json().get('pergunta')),escape(messageid))
    userNumber = escape(messageid).split(sep='@')[0]
    userMessage = escape(request.get_json().get('userMessage'))
    try:
        respostaDaAi = getAIAnswer(f"{userMessage}",f"{userNumber}",f"{userNumber[-1]}")
        return respostaDaAi  
    except Exception as e:
        print(e)
        return "tive um problema processando a sua pergunta. Por favor, tente novamente."





#python -m flask --app indexV3 run