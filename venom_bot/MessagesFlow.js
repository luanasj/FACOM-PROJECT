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

const {getChat,updateChatState,addChat} = require("./chats")
const {content} = require("./menu")

const messageHandler = (message) =>{
  const phoneNumber = message.from

  const chat = getChat(phoneNumber)

  if(!chat) {
    addChat(phoneNumber)
    chat = getChat(phoneNumber)
  }

  if(message.body == "0") {
    updateChatState(phoneNumber,-1,content.length-1)
    chat = getChat(phoneNumber)
    return content[chat.state](chat,message.body)
  }

  const response = content[chat.state](chat,message.body)

  if(response) {
    updateChatState(phoneNumber,1,content.length-1)
    return response
  }

  return "Resposta inválida, por favor responda com o número referente a uma das opções";
}






