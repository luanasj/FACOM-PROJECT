const chats = new Array()

const chatRemoval = (tel)=>{
    const chatIndex = chats.indexOf(getChat(tel))
    chats.splice(chatIndex,1)
    console.log("removendo chat tel:",tel)
    console.log(chatIndex)
}

const conversationEnding = (tel)=>{
    const chatIndex = chats.indexOf(getChat(tel))

    if(chats[chatIndex].timeout) clearTimeout(chats[chatIndex].timeout);

    return setTimeout(chatRemoval,450000,[tel])
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
        chats[chatIndex].timeout = conversationEnding(tel)
    }

}

const updateOption = (tel,option)=>{
    const chatIndex = chats.indexOf(getChat(tel))
    chats[chatIndex].option = option ?? null

}

const addChat = (tel) =>{
    chats.push({
            tel: tel,
            state: 0,
            option:null,
            timeout: 0
    })
}


module.exports = {chats,getChat,updateChatState,updateOption,addChat}

