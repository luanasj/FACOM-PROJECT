const dados = require('../assets/externalInfo.json')
const utilInfo = require("../assets/utilInfo.json")

const initial = (chat,message) => {
    const initialText = utilInfo.greetingText+"\n\nEscolha uma das oções abaixo digitando o número da opção desejada.\n\n"

    return initialText + dados.map((section,index)=>`${index + 1} ${section.topic}`).join("\n")
}

const stateOne = (chat,message)=>{
    return "Escolha uma das opções abaixo:\n\n" + dados[message]?.subtopics.map((topic,index) => `${index + 1} ${topic.name}`).join("\n") + "\n\nDigite 0 para retornar ao menu anterior"
}

const stateTwo = (chat,message)=>{
    const response = dados[chat.option]?.subtopics[message]?.description

    return  response ? response + "\n\nDigite 0 para retornar ao menu anterior" : response
}

const content = [initial,stateOne,stateTwo]

module.exports = {content}













