from dotenv import load_dotenv
load_dotenv()

from typing import Literal

from langchain_core.prompts import ChatPromptTemplate
from langchain_groq import ChatGroq

from pydantic import BaseModel, Field

# Data model
class Decide_to_RAG(BaseModel):
    """
    Invokes the agent model to generate a response based on the current state. Given
    the question, it will decide to route retrieve using the retriever tool, or simply generate.

    """

    method: Literal["generate","route"] = Field(
        ...,
        description="Given a user question choose to send it to generate or route.",
    )

# def agent(state):
#     """
#     Invokes the agent model to generate a response based on the current state. Given
#     the question, it will decide to retrieve using the retriever tool, or simply end.

#     Args:
#         state (messages): The current state

#     Returns:
#         dict: The updated state with the agent response appended to messages
#     """
#     print("---CALL AGENT---")
#     messages = state["messages"]
#     model = ChatOpenAI(temperature=0, streaming=True, model="gpt-4-turbo")
#     model = model.bind_tools(tools)
#     response = model.invoke(messages)
#     # We return a list, because this will get added to the existing list
#     return {"messages": [response]}



# LLM with function call
llm = ChatGroq(model="llama3-8b-8192",temperature=0)
structured_llm_decision_maker = llm.with_structured_output(Decide_to_RAG)

# Prompt
system = """You are an expert at deciding, based on a question, to route to retriever tool or generate an answer.
To route is needed when the question needs context to be answered.
To generate is needed to answer simple direct questions and is needed too if it's not clear  which tool you must call.



""" 

system2 = """
    You are an expert at deciding, based on a user message, to route to retriever tool or generate an answer.
    To route is needed for questions about FACOM(Faculdade de Comunicação UFBA), college/university, 
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
        return "generate"





while (question != "end"):
    print(callQuestion(question))
#     print(agent_router.invoke({"question": question}))
    question = input("Make your question: ")





