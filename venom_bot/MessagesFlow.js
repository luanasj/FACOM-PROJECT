import {isMenuSelector,getSelectorContent} from './menu.js'


function sendTextToUser(client,message,answer){
  client
          .sendText(message.from, answer)
          .then((result) => {
            console.log('Result: ', result); //return object success
          })
          .catch((erro) => {
            console.error('Error when sending: ', erro); //return object error
          });
}

async function getAnswerFromChatBot(message){
  const response = await fetch(`http://127.0.0.1:5000/aimessage/${message.from}`,
        {method:"POST",
        headers: {'Content-Type': 'application/json'},
        body:JSON.stringify({
            userMessage:`${message.body}`
        })})
        .then(dados=>dados.text())
        .then(res => {return res})
  return response
}

async function getAnswer(message){
  if(message.body.length < 2 && isMenuSelector(message.body)){
    //RESPOSTA MENU
    return getSelectorContent(message.body)
  }
  //RESPOSTA CHATBOT
  return await getAnswerFromChatBot(message)
}

async function tradeMessageWithChatbot(client,message) {
  const response = await getAnswer(message)
  sendTextToUser(client,message,response)
}

export {tradeMessageWithChatbot}




