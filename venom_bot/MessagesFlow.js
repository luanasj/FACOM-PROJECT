const {ChatState} = require("venom-bot")
const {getChat,updateChatState,updateOption,addChat} = require("./chats")
const {content} = require("./menu")

const messageHandler = async (message,client) =>{
  const phoneNumber = message.from

  if(!getChat(phoneNumber)) {
    addChat(phoneNumber,client)
  }

  let chat = getChat(phoneNumber)


  if((message.body == "0") && (chat.state > 0)) {
    // console.log("chat state",chat.state)
    // console.log("chat options",chat.options)
    await updateChatState(phoneNumber,-1,content.length)
    await updateOption(phoneNumber,null)
    
    if(!parseInt(chat.state)) await updateChatState(phoneNumber,1,content.length)

    const response = content[chat.state-1](chat,chat.option[0])
    // console.log("response",response)
    // console.log("chat state",chat.state)
    // console.log("chat options",chat.option)
    return response

  }

  const response = content[chat.state] ? content[chat.state](chat,parseInt(message.body)-1) : undefined;
  // console.log(chat.state)
  // console.log(response)

  if(response) {
    await updateChatState(phoneNumber,1,content.length)
    await updateOption(phoneNumber,parseInt(message.body));

    console.log(chat.state)
    console.log("chat options",chat.option)

    return response

  }

  return "Opção inválida, por favor tente novamente ou digite 0 para retornar ao menu anterior.";
}

const messagesSent = new Set();


function sendTextToUser(client,message,answer){
  const chave = `${message.from}-${answer}`;
  if (messagesSent.has(chave)) return;

  messagesSent.add(chave);
  setTimeout(() => messagesSent.delete(chave), 30000);

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
  const response = await messageHandler(message,client)
  sendTextToUser(client,message,response)
}

module.exports = {answerToMedia, tradeMessageWithChatbot}










