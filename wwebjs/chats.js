const chats = new Array()

const chatRemovalNotice = async (chatIndex)=>{
    const chat = chats[chatIndex]
    await chat.client
          .sendText(chat.tel,"Essa conversa está sendo finalizada por inatividade. Para iniciar novamente, envie uma mensagem de texto.")
          .then((result) => {
            return
          })
          .catch((erro) => {
            console.error('Error when sending: ', erro); 
          });
}

const chatRemoval = async (tel)=>{
    const chatIndex = chats.indexOf(getChat(tel))
    
    await chatRemovalNotice(chatIndex)

    chats.splice(chatIndex,1)

    // console.log("removendo chat tel:",tel)
    // console.log(chatIndex)
}

const conversationEnding = (tel)=>{
    const chatIndex = chats.indexOf(getChat(tel))

    if(chats[chatIndex].timeout) clearTimeout(chats[chatIndex].timeout);

    return setTimeout(chatRemoval,6*900000,[tel])
    // return setTimeout(chatRemoval,450000,[tel])

}


const getChat = (tel)=>{
   return chats.find(value => value.tel == tel)
}

const updateChatState = async (tel,increment,maxState)=>{
    
    const chatIndex = chats.indexOf(getChat(tel))

    const currentState = chats[chatIndex].state 

    const newState = currentState + increment

    if (newState >= 0 && newState <= maxState) {
        chats[chatIndex].state = newState
        chats[chatIndex].timeout = conversationEnding(tel)
    }

    return
}

const updateOption = async (tel,option)=>{
    const chatIndex = chats.indexOf(getChat(tel))

    const rollback = (chatIndex)=>{
        chats[chatIndex].option.shift()
    }

    const forward = (chatIndex,option)=>{
        chats[chatIndex].option.unshift(option-1)
    }

    option ? forward(chatIndex,option) : rollback(chatIndex) ;

    return
}

const addChat = (tel,client) =>{
    chats.push({
            tel: tel,
            state: 0,
            option:[],
            timeout: 0,
            client: client
    })
}


module.exports = {chats,getChat,updateChatState,updateOption,addChat}

