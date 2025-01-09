const chatbotEndpoint = "http://127.0.0.1:5000/aimessage"

async function getAnswerFromChatBot(message){
  const response = await fetch(`${chatbotEndpoint}/${message.from}`,
        {method:"POST",
        headers: {'Content-Type': 'application/json'},
        body:JSON.stringify({
            userMessage:`${message}`
        })})
        .then(dados=>dados.text())
        .then(res => {return res})
  console.log( response)
}

getAnswerFromChatBot("Sou da facom, como faço meu salvadorcard?")