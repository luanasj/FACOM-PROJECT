from dotenv import load_dotenv
load_dotenv()
# #generation prompt "luanasjdev/rag-prompt-with-chat-history"

###RAG Tools 

## Get Index of Information and Search tool

from RAG.tools import retriever, web_search_tool

## Get agents (routers, graders and generaters)

from agents.agents import agent_router, question_router, retrieval_grader, hallucination_grader, answer_grader, question_rewriter, rag_chain,no_rag_chain

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

from graphFlow.nodes import retrieve,generate,generate_without_rag,grade_documents,transform_query,web_search,route_question,decide_to_generate

# def retrieve(state):
#     """
#     Retrieve documents

#     Args:
#         state (dict): The current graph state

#     Returns:
#         state (dict): New key added to state, documents, that contains retrieved documents
#     """
#     print("---RETRIEVE---")

#     question = state["question"][-1].content
    

#     # Retrieval
#     documents = retriever.invoke(question)
#     return {"documents": documents, "question": [HumanMessage(content=f"{question}")]}

# def generate(state):
#     """
#     Generate answer

#     Args:
#         state (dict): The current graph state

#     Returns:
#         state (dict): New key added to state, generation, that contains LLM generation
#     """
#     print("---GENERATE---")
#     question = state["question"][-1]
#     question = question.content
#     documents = state["documents"]
#     historyEnd = len(state["messages"]) - 1
#     history = state["messages"][historyEnd-4:historyEnd]
    
    

#     # RAG generation
#     generation = rag_chain.invoke({"context": documents, "question": question,"history":history})
#     return {"documents": documents, "question": [HumanMessage(content=f"{question}")], "generation": generation, "messages":[HumanMessage(content=f"{question}"),AIMessage(content=f"{generation}")]}

# def generate_without_rag(state):
#     """
#     Generate answer

#     Args:
#         state (dict): The current graph state

#     Returns:
#         state (dict): New key added to state, generation, that contains LLM generation
#     """
#     print("---GENERATE---")
#     question = state["question"][-1]
#     documents = ""
#     historyEnd = len(state["messages"]) - 1
#     history = state["messages"][historyEnd-4:historyEnd]
    
    

#     # RAG generation
#     generation = no_rag_chain.invoke({"messages": history+[question]})
#     return {"documents": documents, "question": [HumanMessage(content=f"{question}")], "generation": generation, "messages":[HumanMessage(content=f"{question}"),AIMessage(content=f"{generation}")]}



# def grade_documents(state):
#     """
#     Determines whether the retrieved documents are relevant to the question.

#     Args:
#         state (dict): The current graph state

#     Returns:
#         state (dict): Updates documents key with only filtered relevant documents
#     """

#     print("---CHECK DOCUMENT RELEVANCE TO QUESTION---")
#     question = state["question"][-1]
#     question = question.content    
#     documents = state["documents"]

#     # Score each doc
#     filtered_docs = []
#     for d in documents:
#         score = retrieval_grader.invoke(
#             {"question": question, "document": d.page_content}
#         )
#         grade = score.binary_score
#         if grade == "yes":
#             print("---GRADE: DOCUMENT RELEVANT---")
#             filtered_docs.append(d)
#         else:
#             print("---GRADE: DOCUMENT NOT RELEVANT---")
#             continue
#     return {"documents": filtered_docs, "question": [HumanMessage(content=f"{question}")]}


# def transform_query(state):
#     """
#     Transform the query to produce a better question.

#     Args:
#         state (dict): The current graph state

#     Returns:
#         state (dict): Updates question key with a re-phrased question
#     """

#     print("---TRANSFORM QUERY---")
#     question = state["question"][-1]
#     question = question.content
#     documents = state["documents"]

#     # Re-write question
#     better_question = question_rewriter.invoke({"question": question})
#     return {"documents": documents, "question": [HumanMessage(content=f"{better_question}")]}

# def web_search(state):
#     """
#     Web search based on the re-phrased question.

#     Args:
#         state (dict): The current graph state

#     Returns:
#         state (dict): Updates documents key with appended web results
#     """

#     print("---WEB SEARCH---")
#     question = state["question"][-1]
#     question = question.content

#     # Web search
#     docs = web_search_tool.invoke({"query": question})
#     web_results = "\n".join([d["content"] for d in docs])
#     web_results = Document(page_content=web_results)

#     return {"documents": web_results, "question": [HumanMessage(content=f"{question}")]}



# def route_question(state):
#     """
#     Route question to web search or RAG.

#     Args:
#         state (dict): The current graph state

#     Returns:
#         str: Next node to call
#     """

#     print("---ROUTE QUESTION---")
#     question = state["question"][-1]
#     question = question.content
#     source = question_router.invoke({"question": question})
#     try:
#         decision =  agent_router.invoke({"question": question})
#     except Exception:
#         decision = AIMessage(content='content',method='generate')
#     if decision.method == "generate":
#         print("---ROUTE QUESTION TO GENERATE---")
#         return "generate"
#     elif decision.method == "retrieve":
#         source = question_router.invoke({"question": question})
#         if source.datasource == "web_search":
#             print("---ROUTE QUESTION TO WEB SEARCH---")
#             return "web_search"
#         elif source.datasource == "vectorstore":
#             print("---ROUTE QUESTION TO RAG---")
#             return "vectorstore"

#     # source = question_router.invoke({"question": question})
#     # if source.datasource == "web_search":
#     #     print("---ROUTE QUESTION TO WEB SEARCH---")
#     #     return "web_search"
#     # elif source.datasource == "vectorstore":
#     #     print("---ROUTE QUESTION TO RAG---")
#     #     return "vectorstore"


# def decide_to_generate(state):
#     """
#     Determines whether to generate an answer, or re-generate a question.

#     Args:
#         state (dict): The current graph state

#     Returns:
#         str: Binary decision for next node to call
#     """

#     print("---ASSESS GRADED DOCUMENTS---")
#     state["question"][-1].content
#     filtered_documents = state["documents"]

#     if not filtered_documents:
#         # All documents have been filtered check_relevance
#         # We will re-generate a new query
#         print(
#             "---DECISION: ALL DOCUMENTS ARE NOT RELEVANT TO QUESTION, TRANSFORM QUERY---"
#         )
#         return "transform_query"
#     else:
#         # We have relevant documents, so generate answer
#         print("---DECISION: GENERATE---")
#         return "generate"


# def grade_generation_v_documents_and_question(state):
#     """
#     Determines whether the generation is grounded in the document and answers question.

#     Args:
#         state (dict): The current graph state

#     Returns:
#         str: Decision for next node to call
#     """

#     print("---CHECK HALLUCINATIONS---")
#     question = state["question"][-1]
#     question = question.content
#     documents = state["documents"]
#     generation = state["generation"]

#     score = hallucination_grader.invoke(
#         {"documents": documents, "generation": generation}
#     )
#     grade = score.binary_score

#     # Check hallucination
#     if grade == "yes":
#         print("---DECISION: GENERATION IS GROUNDED IN DOCUMENTS---")
#         # Check question-answering
#         print("---GRADE GENERATION vs QUESTION---")
#         score = answer_grader.invoke({"question": question, "generation": generation})
#         grade = score.binary_score
#         if grade == "yes":
#             print("---DECISION: GENERATION ADDRESSES QUESTION---")
#             return "useful"
#         else:
#             print("---DECISION: GENERATION DOES NOT ADDRESS QUESTION---")
#             return "not useful"
#     else:
#         print("---DECISION: GENERATION IS NOT GROUNDED IN DOCUMENTS, RE-TRY---")
#         return "not supported"


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