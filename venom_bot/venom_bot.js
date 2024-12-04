
import venom from 'venom-bot'
import {isMenuSelector,getSelectorContent} from './menu.js'
// import fs from 'fs'

function start(client) {
  client.onMessage(async (message) => {
      if (message.body) {

          if(message.body.length < 2 && isMenuSelector(message.body)){
            //RESPOSTA MENU

            const resposta = getSelectorContent(message.body)
            client
            .sendText(message.from, resposta)
            .then((result) => {
              console.log('Result: ', result); //return object success
            })
            .catch((erro) => {
              console.error('Error when sending: ', erro); //return object error
            });

          } else {
            //RESPOSTA CHATBOT

            const resposta = await fetch(`http://127.0.0.1:5000/aimessage/${message.from}`,
            {method:"POST",
            headers: { 'Content-Type': 'application/json' },
            body:JSON.stringify({
                userMessage:`${message.body}`
            })})
            .then(dados=>dados.text())
            .then(res => {return res})
      
            client
              .sendText(message.from, resposta)
              .then((result) => {
                console.log('Result: ', result); //return object success
              })
              .catch((erro) => {
                console.error('Error when sending: ', erro); //return object error
              });
          }






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

