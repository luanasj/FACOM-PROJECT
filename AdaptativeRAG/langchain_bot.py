from dotenv import load_dotenv
load_dotenv()
import os

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

from langchain_core.messages import  HumanMessage

from graphFlow.nodes import retrieve,generate,generate_without_rag,grade_documents,transform_query,web_search,route_question,decide_to_generate


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

workflow.add_edge("generate",END)

#Persistence
from langgraph.checkpoint.memory import MemorySaver

memory = MemorySaver()

# Compile
compiled_workflow = workflow.compile(checkpointer=memory)


## utilitary functions

from support.functions import clearFolder,getAIAnswer

import signal
import sys

def sigint_handler(sig, frame):
    tempFolderPath = os.getenv("commonPathBot")+'\\temp\\*'
    clearFolder(tempFolderPath)
    sys.exit(0)

# Run

from flask import Flask,request
from markupsafe import escape

app = Flask(__name__)

@app.route("/")
def hello_world():
    return "<p>Hello, World!</p>"


@app.route("/aimessage/<messageid>",methods=["POST"])
def hello(messageid):
    userNumber = escape(messageid).split(sep='@')[0]
    userMessage = escape(request.get_json().get('userMessage'))
    try:
        respostaDaAI = getAIAnswer(compiled_workflow,f"{userMessage}",f"{userNumber}",f"{userNumber[-1]}")
        return respostaDaAI  
    except Exception as e:
        print(e)
        return "tive um problema processando a sua pergunta. Por favor, tente novamente."

signal.signal(signal.SIGINT, sigint_handler)

#gitfile run