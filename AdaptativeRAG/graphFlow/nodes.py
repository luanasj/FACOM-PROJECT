import sys 
import os 
# # Adicionando o diretório 'RAG' e 'agents' ao sys.path 
sys.path.append(os.path.join(os.path.dirname(__file__), f"{os.getenv('commonPathBot')}\\AdaptativeRAG"))

## Get Index of Information and Search tool
from RAG.tools import retriever, web_search_tool

##Importando agentes langchain
from agents.agents import agent_router, question_router, retrieval_grader, hallucination_grader, answer_grader, question_rewriter, rag_chain,no_rag_chain

##Construindo funções/nodes
from langchain.schema import Document
from langchain_core.messages import HumanMessage,AIMessage

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
