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
    return dados.map(section=>section.topic)
}

const stateOne = (chat,message)=>{
    return dados[message]?.subtopics.map(topic => topic.name)
}

const stateTwo = (chat,message)=>{
    const isNumber = typeof(message) === "number"
    return dados[chat.option]?.subtopics[message].description
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
//     option: 0},1))












