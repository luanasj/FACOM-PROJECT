from dotenv import load_dotenv
load_dotenv()

#Define LLM

from langchain_groq import ChatGroq

llm = ChatGroq(model="llama3-8b-8192",temperature=0)

### Routers

from typing import Literal

from pydantic import BaseModel, Field

## Route to retrieve or generate

#Data Model
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
structured_llm_decision_maker = llm.with_structured_output(rag_or_generate)

## Route to vectorstore or web_search

#Data Model
class RouteQuery(BaseModel):
    """Route a user query to the most relevant datasource."""

    datasource: Literal["vectorstore", "web_search"] = Field(
        ...,
        description="Given a user question choose to route it to web search or a vectorstore.",
    )
# LLM with function call
structured_llm_router = llm.with_structured_output(RouteQuery)

###Graders

## Retrieval Grader

# Data model
class GradeDocuments(BaseModel):
    """Binary score for relevance check on retrieved documents."""

    binary_score: str = Field(
        description="Documents are relevant to the question, 'yes' or 'no'"
    )

# LLM with function call
structured_llm_retrieval_grader = llm.with_structured_output(GradeDocuments)

## Hallucination Grader

# Data model
class GradeHallucinations(BaseModel):
    """Binary score for hallucination present in generation answer."""

    binary_score: str = Field(
        description="Answer is grounded in the facts, 'yes' or 'no'"
    )


# LLM with function call
structured_llm_hallucination_grader = llm.with_structured_output(GradeHallucinations)

## Answer Grader

# Data model
class GradeAnswer(BaseModel):
    """Binary score to assess answer addresses question."""

    binary_score: str = Field(
        description="Answer addresses the question, 'yes' or 'no'"
    )

# LLM with function call
structured_llm_answer_grader = llm.with_structured_output(GradeAnswer)



