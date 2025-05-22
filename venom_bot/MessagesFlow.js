const {getChat,updateChatState,updateOption,addChat} = require("./chats")
const {content} = require("./menu")

const messageHandler = async (message) =>{
  const phoneNumber = message.from

  if(!getChat(phoneNumber)) {
    addChat(phoneNumber)
  }

  let chat = getChat(phoneNumber)


  if((message.body == "0") && (chat.state > 0)) {
    await updateChatState(phoneNumber,-1,content.length-1)
    await updateOption(phoneNumber,null)

    const response = content[chat.state](chat,message.body)

    if(!parseInt(chat.state)) await updateChatState(phoneNumber,1,content.length-1)


    return response

  }

  const response = content[chat.state](chat,parseInt(message.body)-1)

  if(response) {
    await updateChatState(phoneNumber,1,content.length-1)
    await updateOption(phoneNumber,parseInt(message.body)-1)
    return response
  }

  return "Opção inválida, por favor tente novamente ou digite 0 para retornar ao menu anterior";
}

function sendTextToUser(client,message,answer){
  client
          .sendText(message.from, answer)
          .then((result) => {
            return
          })
          .catch((erro) => {
            console.error('Error when sending: ', erro); 
          });
}

function answerToMedia(client,message){
  // RESPOSTA MENSAGEM DE MÍDIA
  const response = "Sinto muito, mas não consigo processar este formato de mensagem.\nPor favor envie uma mensagem de texto."
  sendTextToUser(client,message,response) 
}

async function tradeMessageWithChatbot(client,message) {
  const response = await messageHandler(message)
  sendTextToUser(client,message,response)
}

module.exports = {answerToMedia, tradeMessageWithChatbot}










