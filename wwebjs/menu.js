const fs = require('fs')
const path = require('path')

const ASSETS_DIR = process.env.FACOM_ASSETS_DIR || path.resolve(__dirname, '..', 'assets')
const dados = JSON.parse(fs.readFileSync(path.join(ASSETS_DIR, 'externalInfo.json'), 'utf8'))
const utilInfo = JSON.parse(fs.readFileSync(path.join(ASSETS_DIR, 'utilInfo.json'), 'utf8'))

const initial = (chat,message) => {
    const initialText = utilInfo.greetingText+"\n\nEscolha uma das oções abaixo digitando o número da opção desejada.\n\n"

    return initialText + dados.map((section,index)=>`${index + 1} ${section.topic}`).join("\n")
}

const stateOne = (chat,message)=>{
    const response = dados[message]?.subtopics.map((topic,index) => `${index + 1} ${topic.name}`).join("\n")

    return response ? "Escolha uma das opções abaixo:\n\n" + response + "\n\nDigite 0 para retornar ao menu anterior" : response
}

const stateTwo = (chat,message)=>{
    const response = dados[chat.option[0]]?.subtopics[message]?.description

    return  response ? response + "\n\nDigite 0 para retornar ao menu anterior" : response
}

const content = [initial,stateOne,stateTwo]

module.exports = {content}
