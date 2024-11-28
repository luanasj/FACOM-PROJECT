fetch("http://127.0.0.1:5000/luana",{
    method:"POST",
    headers: { 'Content-Type': 'application/json' },
    body:JSON.stringify({
        pergunta:"eu sou uma pergunta"
    })
}).then(data=>data.text())
.then(res=>console.log(res))