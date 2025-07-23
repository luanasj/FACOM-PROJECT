const venom = require('venom-bot')
const {tradeMessageWithChatbot,answerToMedia} = require('./MessagesFlow.js')
const {WppCounter,log} = require('./utils.js')

function start(client) {

  
  const counter = new WppCounter(180,client);

  //Se comunica com o chatbot
  client.onMessage(async (message) => {
    if(!message.isGroupMsg){
      if (['chat','conversation','extendedTextMessage'].includes(message.type)) {
          tradeMessageWithChatbot(client,message)
      }else if(["e2e_notification","notification_template"].includes(message.type)){
        //nothing happens here
      } else{
          answerToMedia(client,message)
          log(message.type)
      }
    }
    // console.log(message)
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
  .then((client) => {start(client)})
  .catch((erro) => {
    console.log(erro);
  });
