const { Client } = require('whatsapp-web.js')
const puppeteer = require('puppeteer')
const {tradeMessageWithChatbot,answerToMedia} = require('./MessagesFlow.js')
const {WppCounter,log,isGroupMsg} = require('./utils.js')

const client = new Client({
    puppeteer: {
        headless: false,
        executablePath: puppeteer.executablePath(),
        args: ['--no-sandbox', '--disable-setuid-sandbox']
    }
});

const counter = new WppCounter(180,client);

// When the client is ready, run this code (only once)
client.once('ready', () => {
    console.log('Client is ready!');
});

//Listening to all incoming messages
client.on('message_create', message => 
    console.log(message)
)

client.on('message', message => {
    if (message.from === 'status@broadcast' || message.isStatus) return;
	if (message.body && (message.type === 'chat') && !isGroupMsg(message)) {
        tradeMessageWithChatbot(client,message)
	} else {
        answerToMedia(client,message)
        log(message.type)
    }
});


client.on('change_state', (state) => {
    console.log('Estado da conexão:', state);
    if (state === 'DISCONNECTED' || state === 'SYNCING') {
      setTimeout(() => {
        client.destroy(); // ou client.logout() dependendo do caso
      }, 80000);
    }
});


process.on('SIGINT', () => {
    client.destroy(); // ou client.logout()
    process.exit();
});
  

client.initialize();

