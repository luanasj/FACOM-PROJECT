import json

def getSelectorsFromJSON(jsonPath):
    with open(jsonPath, 'r',encoding='utf-8') as arquivo:
        dadosJSON = json.load(arquivo)

    selectors = ""

    for i in range(len(dadosJSON)):
        item = dadosJSON[i]
        selectors += f"{i+1} {item['name']}\n"

    # selectors += f"{len(dadosJSON)+1} Outros" 

    return selectors
