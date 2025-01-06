import dados from '../externalInfo.json' assert { type: 'json' };

const selectorStore = dados

const getSelectorsList = ()=>{
    let selectors = []
    for (let i in selectorStore){
        const selectorNumber = (parseInt(i)+1).toString()
        selectors.push(selectorNumber)
    }

    return selectors
}

const isMenuSelector = (message)=>{
    return getSelectorsList(selectorStore).includes(message)  
}

const getSelectorContent = (message)=>{
    return selectorStore[message].description
}

export {isMenuSelector,getSelectorContent}







