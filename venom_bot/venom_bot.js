const venom = require('venom-bot');
const fs = require('fs');

function start(client) {
  client.onMessage(async (message) => {
      if (message.body) {
      console.log(message.body)
      // const resposta = await fetch("http://127.0.0.1:5000/aimessage", {method:"POST", body: JSON.stringify(message.body)})
      // .then(res=>res.json())
      // .then(resposta => {return resposta})

      const resposta = await fetch(`http://127.0.0.1:5000/aimessage/${message.body}/${message.from}`)
      .then(res=>res.text())
      .then(resposta => {return resposta})

      client
        .sendText(message.from, resposta)
        .then((result) => {
          console.log('Result: ', result); //return object success
        })
        .catch((erro) => {
          console.error('Error when sending: ', erro); //return object error
        });
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

