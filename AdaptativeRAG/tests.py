from dotenv import load_dotenv
load_dotenv()

import json
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_core.output_parsers import StrOutputParser
from langchain_groq import ChatGroq


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

print(no_rag_chain.invoke({"messages":[input()]}))





