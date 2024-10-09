from dotenv import load_dotenv
load_dotenv()

from typing import Literal

from langchain_core.prompts import ChatPromptTemplate
from langchain_core.messages import AIMessage

from langchain_groq import ChatGroq

from pydantic import BaseModel, Field

# Data model
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
llm = ChatGroq(model="llama3-8b-8192",temperature=0)
structured_llm_decision_maker = llm.with_structured_output(rag_or_generate)

# Prompt
system = """You are an expert at deciding, based on a question, to retrieve or generate an answer.
To retrieve is needed when the question needs context to be answered.
To generate is needed to answer simple direct questions and is needed too if it's not clear  which tool you must call.



""" 

system2 = """
    You are an expert at deciding, based on a user message, to retrieve or generate an answer.
    To retrieve is needed for questions about FACOM(Faculdade de Comunicação UFBA), college/university, 
    enrolment, grades. Otherwise call generate.
     
""" 

#For any other sentence, user doubts or requests, answer generate. 
#  Also, if you can't decide a tool, call generate.

agent_prompt = ChatPromptTemplate.from_messages(
    [
        ("system", system2),
        ("user", "{question}"),
    ]
)

agent_router = agent_prompt | structured_llm_decision_maker

question = input("Make your question: ")

# print(agent_router.invoke({"question": "What are the types of agent memory?"}))

def callQuestion(question):
    try:
        return  agent_router.invoke({"question": question})
    except Exception:
        return AIMessage(content='content',method='generate')




while (question != "end"):
    print(callQuestion(question))
#     print(agent_router.invoke({"question": question}))
    question = input("Make your question: ")

##Create rag_or_generate router

def rag_or_generate(state):
    """
    Given a question, it will decide retrieve using the retrieving tools,
    or simply generate an answer.

    Args:
        state (question): user question

    Returns:
        str: Next node to call
    """
    print("---ROUTE QUESTION---")
    question = state["question"]
    source = agent_router.invoke({"question": question})
    if source.method == "generate":
        print("---ROUTE QUESTION TO GENERATE---")
        return "generate"
    elif source.method == "retrieve":
        print("---ROUTE QUESTION TO RETRIEVE---")
        return "retrieve"







