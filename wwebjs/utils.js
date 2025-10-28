const dados = require('../assets/utilInfo.json')
const fs = require('fs')

class WppCounter{
    FACOMnumber = dados.phoneNumber

    constructor(seconds,client){
        setInterval(() => {
            client.sendMessage(`${this.FACOMnumber}@c.us`,"Confirmação de atividade")
        }, seconds*1000);
    }

}

const logStream = fs.createWriteStream('logs.txt', { flags: 'a' }); // 'a' = append

function log(message) {
  const timestamp = new Date().toISOString();
  try {
      logStream.write(`[${timestamp}] ${message}\n`);
  } catch {
    // 
  }
}


// client.on('message', async (message) => {
//   if (message.from.endsWith('@g.us')) {
//       console.log('Mensagem de grupo');
//   } else {
//       console.log('Mensagem privada');
//   }
// });


function isGroupMsg (message) {
  return message.from.endsWith('@g.us')
}

module.exports = {WppCounter,log,isGroupMsg}