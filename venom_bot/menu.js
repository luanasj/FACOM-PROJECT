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



console.log(isMenuSelector("1"))
console.log(getSelectorContent("1"))


export {isMenuSelector,getSelectorContent}

// const menuSelectorContent = (selector)=>{
//     let message = [1,7,8,9]

// }

// console.log(selectorStore.)






