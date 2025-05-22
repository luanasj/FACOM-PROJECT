// import dados from '../assets/externalInfo.json' assert { type: 'json' };


// const getSelectorsList = ()=>{
//     let selectors = []
//     for (let i in selectorStore){
    //         const selectorNumber = (parseInt(i)+1).toString()
//         selectors.push(selectorNumber)
//     }

//     return selectors
// }

// const isMenuSelector = (message)=>{
//     return getSelectorsList(selectorStore).includes(message)  
// }

// const getSelectorContent = (message)=>{
//     return selectorStore[message-1].description
// }

// module.exports = {isMenuSelector,getSelectorContent}


// const topics = dados.map(section=>section.topic)

// const options = dados.map(section=>section.subtopics.name)

// const informations = dados.map(section=>section.subtopics.description)

// const content = [topics,options,informations]

// const getResponse = (state,option) =>{
    //     return state
    // }
const dados = require('../assets/externalInfo.json')

const initial = (chat,message) => {
    const initialText = "Olá! Bem vindo ao FACOM-bot.\n\nEstou aqui para ajudá-lo com informações sobre a FACOM (Faculdade de Comunicação) da UFBA. \n\nEscolha uma das oções abaixo digitando o número da opção desejada.\n\n"

    return initialText + dados.map((section,index)=>`${index + 1} ${section.topic}`).join("\n")
}

const stateOne = (chat,message)=>{
    return "Escolha uma das opções abaixo:\n\n" + dados[message]?.subtopics.map((topic,index) => `${index + 1} ${topic.name}`).join("\n") + "\n\nDigite 0 para retornar ao menu anterior"
}

const stateTwo = (chat,message)=>{
    // const isNumber = typeof(message) === "number"
    const response = dados[chat.option]?.subtopics[message]?.description

    return  response ? response + "\n\nDigite 0 para retornar ao menu anterior" : response
}

const content = [initial,stateOne,stateTwo]

module.exports = {content}

// console.log(initial("kkk","lalalal"))
// console.log(stateOne("kkk",1))
// console.log(stateOne("kkk",27))
// console.log(stateOne("kkk","luana"))
// console.log(stateTwo({
//     tel: 123456,
//     state: 0,
//     option: null},1))












