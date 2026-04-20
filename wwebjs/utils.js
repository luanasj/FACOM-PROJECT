const fs = require('fs')
const path = require('path')

const ASSETS_DIR = process.env.FACOM_ASSETS_DIR || path.resolve(__dirname, '..', 'assets')
const dados = JSON.parse(fs.readFileSync(path.join(ASSETS_DIR, 'utilInfo.json'), 'utf8'))

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
