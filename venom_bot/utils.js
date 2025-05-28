const dados = require('../assets/utilInfo.json')

class WppCounter{
    FACOMnumber = dados.phoneNumber

    constructor(seconds,client){
        setInterval(() => {
            client.sendText(`${this.FACOMnumber}@c.us`,"Confirmação de atividade")
        }, seconds*1000);
    }

}

module.exports = WppCounter