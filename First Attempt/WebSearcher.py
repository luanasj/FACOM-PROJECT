from dotenv import load_dotenv
load_dotenv()

from langchain_community.retrievers import TavilySearchAPIRetriever

from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnablePassthrough
from langchain_groq import ChatGroq


retriever = TavilySearchAPIRetriever(k=3)

query = "what year was breath of the wild released?"

print(retriever.invoke(query))

# prompt = ChatPromptTemplate.from_template(
#     """Answer the question based only on the context provided.

# Context: {context}

# Question: {question}"""
# )

# llm = ChatGroq(
#     model="llama3-8b-8192"
# )


# def format_docs(docs):
#     return "\n\n".join(doc.page_content for doc in docs)


# chain = (
#     {"context": retriever | format_docs, "question": RunnablePassthrough()}
#     | prompt
#     | llm
#     | StrOutputParser()
# )

# # print(chain.invoke("how many units did bretch of the wild sell in 2020"))
# print(chain.invoke("o que é a FACOM UFBA?"))