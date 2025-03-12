class WppCounter{
    // sendMessage;

    constructor(seconds,client,FACOMnumber){
        // this.sendMessage = false;

        setInterval(() => {
            // this.setSendMessage(false);
            client.sendText(`${FACOMnumber}@c.us`,"Confirmação de atividade")
        }, seconds*1000);
    }

    // setSendMessage(bool){
    //     this.sendMessage = bool
    // }

    // getSendMessage(){
    //     return this.sendMessage
    // }

}

export default WppCounter