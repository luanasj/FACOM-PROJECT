const chats = new Array()

// chats.push({
//     tel: 123456,
//     state: 0,
//     option: null
// })

// chats.push({
//     tel: "45678",
//     state: 0,
//     option:null
// })

const chatRemoval = (tel)=>{
    const chatIndex = chats.indexOf(getChat(tel))
    chats.splice(chatIndex,1)
}

const conversationEnding = (tel)=>{
   return setTimeout(chatRemoval,900000,[tel])
}


const getChat = (tel)=>{
   return chats.find(value => value.tel == tel)
}

const updateChatState = (tel,increment,maxState)=>{
    
    const chatIndex = chats.indexOf(getChat(tel))

    const currentState = chats[chatIndex].state 

    const newState = currentState + increment

    if (newState >= 0 && newState <= maxState) {
        chats[chatIndex].state = newState
    }

    // chats[chatIndex].state = (newState <= maxState) && (newState >= 0) ? newState : 0

}

const updateOption = (tel,option)=>{
    const chatIndex = chats.indexOf(getChat(tel))
    chats[chatIndex].option = option ?? null

}

const addChat = (tel) =>{
    chats.push({
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



module.exports = {chats,getChat,updateChatState,updateOption,addChat}

