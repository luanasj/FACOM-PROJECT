import glob
import os

def clearFolder(tempFolderPath):
    arquivos = glob.glob(tempFolderPath)

    for arquivo in arquivos:
        try:
            os.remove(arquivo)
            print(f'{arquivo} foi excluído com sucesso.')
        except Exception as e:
            print(f'Erro ao excluir {arquivo}: {e}')

from langchain_core.messages import  HumanMessage

def getAIAnswer(workflow,question,user_id,thread_id):
    config = {"configurable": {"user_id":user_id,"thread_id": thread_id}}
    input_message = HumanMessage(content=question)


    AIanswer = workflow.invoke({"question": [input_message]}, config, stream_mode="values")
    AIanswerContent = AIanswer["messages"][-1].content
    
    return AIanswerContent