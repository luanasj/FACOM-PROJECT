import dados from '../assets/utilInfo.json' assert {type:'json'}

console.log(dados)

class WppCounter{
    FACOMnumber = dados.phoneNumber

    constructor(seconds,client){
        // this.sendMessage = false;

        setInterval(() => {
            // this.setSendMessage(false);
            client.sendText(`${this.FACOMnumber}@c.us`,"Confirmação de atividade")
        }, seconds*1000);
    }

}

export default WppCounter