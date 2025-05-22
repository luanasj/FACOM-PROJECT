// import {isMenuSelector,getSelectorContent} from './menu.js'
// const { isMenuSelector, getSelectorContent } = require('./menu.js');


// const chatbotEndpoint = "http://127.0.0.1:5000/aimessage"

// function sendTextToUser(client,message,answer){
//   client
//           .sendText(message.from, answer)
//           .then((result) => {
//             // console.log('Result: ', result); //return object success
//             return
//           })
//           .catch((erro) => {
//             console.error('Error when sending: ', erro); //return object error
//           });
// }

// async function getAnswerFromChatBot(message){
//   const response = await fetch(`${chatbotEndpoint}/${message.from}`,
//         {method:"POST",
//         headers: {'Content-Type': 'application/json'},
//         body:JSON.stringify({
//             userMessage:`${message.body}`
//         })})
//         .then(dados=>dados.text())
//         .then(res => {
//           if(res.includes("html")){ throw new Error("Unexpected route used")}
//           return res
//         })
//         .catch(error => {return "Não consegui responder a sua mensagem, por favor, tente novamente em alguns instantes."})
//   return response
// }


// async function getAnswer(message){
//   if(message.body.length < 2 && isMenuSelector(message.body)){
//     //RESPOSTA MENU
//     return getSelectorContent(message.body)
//   } 
//   //RESPOSTA CHATBOT
//   return await getAnswerFromChatBot(message)
// }

// function answerToMedia(client,message){
//   // RESPOSTA MENSAGEM DE MÍDIA
//   const response = "Sinto muito, mas não consigo processar este formato de mensagem.\nPor favor envie uma mensagem de texto."
//   sendTextToUser(client,message,response) 
// }

// async function tradeMessageWithChatbot(client,message) {
//   const response = await getAnswer(message)
//   sendTextToUser(client,message,response)
// }

// module.exports =  {tradeMessageWithChatbot, answerToMedia}

const {getChat,updateChatState,updateOption,addChat} = require("./chats")
const {content} = require("./menu")

const messageHandler = (message) =>{
  const phoneNumber = message.from

  if(!getChat(phoneNumber)) {
    addChat(phoneNumber)
  }

  let chat = getChat(phoneNumber)


  if((message.body == "0") && (chat.state > 0)) {
    updateOption(phoneNumber,null)
    updateChatState(phoneNumber,-1,content.length-1)

    return content[parseInt(chat.state)](chat,message.body)
  }

  const response = content[chat.state](chat,parseInt(message.body)-1)

  if(response) {
    updateOption(phoneNumber,parseInt(message.body)-1)
    updateChatState(phoneNumber,1,content.length-1)
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

function tradeMessageWithChatbot(client,message) {
  const response = messageHandler(message)
  sendTextToUser(client,message,response)
}

module.exports = {answerToMedia, tradeMessageWithChatbot}










