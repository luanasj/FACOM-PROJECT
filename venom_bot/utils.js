const dados = require('../assets/utilInfo.json')
const fs = require('fs')

class WppCounter{
    FACOMnumber = dados.phoneNumber

    constructor(seconds,client){
        setInterval(() => {
            client.sendText(`${this.FACOMnumber}@c.us`,"Confirmação de atividade")
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



module.exports = {WppCounter,log}