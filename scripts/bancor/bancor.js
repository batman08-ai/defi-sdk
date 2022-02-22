const userAddress = '0xD965952823153E5CBc611be87e8322cfc329f056';
const axios = require('axios');
const fs = require('fs');
const API = 'https://api-v2.bancor.network/pools';

const { balanceOf } = require('./utils/smartToken')

let data = '';
let userData = [];

const writeDataToFile = () => {
    return new Promise((resolve, reject) => {
        fs.writeFile(`${__dirname}/output/bancor.json`, data, err => {
            if (err) {
                console.log("Error writing to file", err);
                reject(err);
            } else {
                console.log("Written to file successfully");
                resolve("Written to file successfully");
            }
        })
    })
}

const detailsByBancorV2API = async () => {
    try {
        let balances = [];
        const { data: pools } = (await axios.get(API)).data
        pools.forEach(pool => {
            balances.push(balanceOf(userAddress, pool.dlt_id));
        });
        const balanceResult = await Promise.all(balances)

        balanceResult.forEach((bal, index) => {
            if (bal > 0) {
                userData.push({
                    ...pools[index],
                    tokenBalance: bal
                });
            }
        })
        data += JSON.stringify({
            userData
        })
    } catch (e) {
        console.log("error is: ", e);
        console.log(`API request failed with code ${e.response.status} & message ${e.response.statusText}`);
        throw new Error(`API request failed with ${e.response.statusText}`)
    }
}

(async () => {
    await detailsByBancorV2API();
    await writeDataToFile();
})()