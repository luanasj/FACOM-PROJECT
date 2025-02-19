import venom from 'venom-bot'
import {tradeMessageWithChatbot,answerToMedia} from "./messagesFlow.js"
import WppCounter from "./utils.js"

// const counter = new WppCounter(180);


function start(client) {
  

  // if(counter.getSendMessage()){
  //   counter.setSendMessage(false);
  //   client.sendText(`${FACOMnumber}@c.us`,"Confirmação de atividade");
  // }
  const FACOMnumber = "5511947270112"
  const counter = new WppCounter(180,client,FACOMnumber);

  //Se comunica com o chatbot
  client.onMessage(async (message) => {
    if (message.type == 'chat') {
        tradeMessageWithChatbot(client,message)
    }else{
        answerToMedia(client,message)
    }
  });

  // Ajuda a menter a sessãoo ativa
  client.onStateChange((state) => {
    console.log('State changed: ', state);
    // force whatsapp take over
    if ('CONFLICT'.includes(state)) client.useHere();
    // detect disconnect on whatsapp
    if ('UNPAIRED'.includes(state)) console.log('logout');
  });
  
  
  let time = 0;
  client.onStreamChange((state) => {
    console.log('State Connection Stream: ' + state);
    clearTimeout(time);
    if (state === 'DISCONNECTED' || state === 'SYNCING') {
      time = setTimeout(() => {
        client.close();
      }, 80000);
    }
  });
  
  // function to detect incoming call
  client.onIncomingCall(async (call) => {
    client.sendText(call.peerJid, "Sinto muito, eu não atendo ligações.");
    
  });


  //Fecha corretamente o cliente quando o processo é encerrado
  process.on('SIGINT', function() {
    client.close();
  });
}

venom
  .create({
    session: "session_facom_1", //name of session
    headless: false
  })
  .then((client) => {start(client);console.log(client)})
  .catch((erro) => {
    console.log(erro);
  });



