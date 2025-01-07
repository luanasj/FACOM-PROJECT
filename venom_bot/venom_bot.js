
import venom from 'venom-bot'
import {tradeMessageWithChatbot,answerToMedia} from "./messagesFlow.js"
// import fs from 'fs'

function start(client) {
  client.onMessage(async (message) => {
    if (message.type == 'chat') {
        tradeMessageWithChatbot(client,message)
    }else{
        answerToMedia(client,message)
    }
  });
}

venom
  .create({
    session: "session_facom_1", //name of session
    headless: false
  })
  .then((client) => start(client))
  .catch((erro) => {
    console.log(erro);
  });



