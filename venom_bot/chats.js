const chats = new Array()

chats.push({
    tel: 123456,
    state: 0,
    option: null
})

chats.push({
    tel: "45678",
    state: 0,
    option:null
})

const getChat = (chatsList,tel)=>{
   return chatsList.find(value => value.tel == tel)
}

const updateChatState = (chatsList,tel,increment,maxState)=>{
    
    const chatIndex = chatsList.indexOf(getChat(chatsList,tel))

    const currentState = chats[chatIndex].state 

    chats[chatIndex].state = (currentState < maxState) && (currentState >= 0) ? currentState + (increment) : 0
}

const addChat = (chatsList,tel) =>{
    chatsList.push({
            tel: tel,
            state: 0,
            option:null
    })
}
// console.log(getChat(chats,"123456"))
// console.log(getChat(chats,"586727"))

// console.log(getChat(chats,"123456"))
// updateChatState(chats,123456,1,2)
// console.log(getChat(chats,"123456"))
// updateChatState(chats,123456,-1,2)
// console.log(getChat(chats,"123456"))
// updateChatState(chats,123456,1,2)
// console.log(getChat(chats,"123456"))
// updateChatState(chats,123456,1,2)
// console.log(getChat(chats,"123456"))

//Digite 0 para voltar







// updateChat



module.exports = {chats}

