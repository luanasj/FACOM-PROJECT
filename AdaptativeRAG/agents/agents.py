from dotenv import load_dotenv
load_dotenv()

# # Adicionando o diretório avô 'AdaptativeRAG' ao sys.path 
import sys 
import os 

sys.path.append(os.path.join(os.path.dirname(__file__), os.getenv('commonPathBot') + "\\AdaptativeRAG" ))

from agents.structuredLLM import structured_llm_decision_maker, structured_llm_router, structured_llm_hallucination_grader,structured_llm_retrieval_grader,structured_llm_answer_grader

#Define LLM

from langchain_groq import ChatGroq
llm = ChatGroq(model="llama3-8b-8192",temperature=0)

###Routers

# Route to retrieve or generate

from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser

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

## Route to vectorstore or web search

#VectorStore content description



from RAG.tools import vectorstoreContent

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


route_prompt = ChatPromptTemplate.from_messages(
    [
        ("system", system),
        ("human", "{question}"),
    ]
)

question_router = route_prompt | structured_llm_router

###Graders

## Retrieval Grader

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

retrieval_grader = grade_prompt | structured_llm_retrieval_grader

## Hallucination Grader

# Prompt
system = """You are a grader assessing whether an LLM generation is grounded in / supported by a set of retrieved facts. \n 
     Give a binary score 'yes' or 'no'. 'Yes' means that the answer is grounded in / supported by the set of facts."""
hallucination_prompt = ChatPromptTemplate.from_messages(
    [
        ("system", system),
        ("human", "Set of facts: \n\n {documents} \n\n LLM generation: {generation}"),
    ]
)

hallucination_grader = hallucination_prompt | structured_llm_hallucination_grader

## Answer Grader

# Prompt
system = """You are a grader assessing whether an answer addresses / resolves a question \n 
     Give a binary score 'yes' or 'no'. Yes' means that the answer resolves the question."""
answer_prompt = ChatPromptTemplate.from_messages(
    [
        ("system", system),
        ("human", "User question: \n\n {question} \n\n LLM generation: {generation}"),
    ]
)

answer_grader = answer_prompt | structured_llm_answer_grader

### Question Re-writer

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

### Generate

from langchain import hub
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder

## RAG generate
# Prompt
rag_prompt = hub.pull("luanasjdev/rag-prompt-with-chat-history")


# Chain
rag_chain = rag_prompt | llm | StrOutputParser()


## Generate without RAG

from agents.utils import getSelectorsFromJSON

# Prompt

JSONpath = os.getenv("commonPathBot")+"\\assets\\externalInfo.json"

no_rag_prompt = ChatPromptTemplate.from_messages(
    [(
            "system",
            f'''Você é um assistente preparado para responder informacoes sobre a FACOM (Faculdade de Comunicação) da UFBA. Se a pergunta nao for relacionada à FACOM ou ao contexto universitário diga que não pode responder.

            Caso seja a primeira mensagem do usuário ou uma saudação como "olá", "bom dia", "você pode me ajudar","tenho uma dúvida", peça que o usuário escolha uma das opcções do menu abaixo digitando o número da opção desejada. 

            {getSelectorsFromJSON(JSONpath)}
            
            Caso não seja nenhuma das opções acima, o usuário deve digitar a sua pergunta.
            ''',
        ),
        MessagesPlaceholder(variable_name="messages"),]
)

# Chain
no_rag_chain = no_rag_prompt | llm | StrOutputParser()