const userAddress = '0x6cEDc25F604c7679cA159BB16f94928EbeF1473F';
const curvePoolInfo = require('./utils/curvePoolInfo')
const curvePoolRegistry = require('./utils/curvePoolRegistry')
const LPTokenABI = require('../contract-abis/curve-lp-token.json')
const { getContractFromABIAndAddress } = require('../constants')
const fs = require('fs');
const zeroAddress = '0x0000000000000000000000000000000000000000'

let data = '';

const filterArray = (array, condition) => array.filter(element => element != condition)

const getPoolCoins = async (poolAddress) => {
    try {
        const poolCoins = await curvePoolInfo.poolCoins(poolAddress)

        let { coins, underlying_coins: underlyingCoins, decimals, underlying_decimals: underlyingDecimals } = poolCoins

        coins = filterArray(coins, zeroAddress)
        underlyingCoins = filterArray(underlyingCoins, zeroAddress)
        decimals = filterArray(decimals, 0)
        underlyingDecimals = filterArray(underlyingDecimals, 0)
        return {
            coins, underlyingCoins, decimals, underlyingDecimals
        }
    } catch (e) {
        console.log("Get pool coins error: ", e);
    }
}

const getLPTokenDetails = async (tokenAddress, userAddress) => {
    try {
        const lpTokenContract = getContractFromABIAndAddress(LPTokenABI, tokenAddress)
        const lpTokenDetailPromises = [
            lpTokenContract.methods.name().call(),
            lpTokenContract.methods.symbol().call(),
            lpTokenContract.methods.decimals().call(),
            lpTokenContract.methods.balanceOf(userAddress).call()
        ]
        const lpTokenDetailsResult = await Promise.all(lpTokenDetailPromises)
        const [name, symbol, decimals, userBalance] = lpTokenDetailsResult
        return {
            liquidityProviderDetails: {
                address: tokenAddress,
                name,
                symbol,
                decimals,
                userBalance
            }
        }
    } catch (e) {
        console.log("Get lp token details error: ", e);
    }
}

const getPoolInfo = async (poolAddress) => {
    try {
        const poolInfo = await curvePoolInfo.poolInfo(poolAddress);
        let { balances, underlying_balances: underlyingBalances, rates, lp_token: lpToken, params } = poolInfo;

        balances = filterArray(balances, 0)
        underlyingBalances = filterArray(underlyingBalances, 0)
        rates = filterArray(rates, 0)

        const [A, futureA, fee, adminFee, futureFee, futureAdminFee, futureOwner, initialA, initialATime, futureATime] = params;

        let liquidityProviderDetails = {};

        if (lpToken != zeroAddress) {
            liquidityProviderDetails = await getLPTokenDetails(lpToken, userAddress)
        }

        return {
            balances,
            underlyingBalances,
            rates,
            poolParameters: {
                A, futureA, fee, adminFee, futureFee, futureAdminFee, futureOwner, initialA, initialATime, futureATime
            },
            ...liquidityProviderDetails
        }
    } catch (e) {
        console.log("Get pool info error: ", e, "\t", poolAddress);
    }
}

const getPoolAddresses = async () => {
    const totalPools = await curvePoolRegistry.totalPools();
    let poolAddressPromises = []
    for (let i = 0; i < totalPools; i++) {
        poolAddressPromises.push(curvePoolRegistry.pool(i))
    }
    return Promise.all(poolAddressPromises)
}

const curveInvestmentDetails = async () => {
    let poolCoinsPromises = []
    let poolInfoPromises = []

    const nonReadablePoolAddresses = ['0x43b4FdFD4Ff969587185cDB6f0BD875c5Fc83f8c', '0xd632f22692FaC7611d2AA1C0D552930D43CAEd3B', '0xEcd5e75AFb02eFa118AF914515D6521aaBd189F1', '0x80466c64868E1ab14a1Ddf27A676C3fcBE638Fe5', '0x4807862AA8b2bF68830e4C8dc86D0e9A998e085a', '0xEd279fDD11cA84bEef15AF5D39BB4d4bEE23F0cA', '0xFD5dB7463a3aB53fD211b4af195c5BCCC1A03890', '0x5a6A4D54456819380173272A5E8E9B9904BdF41B']

    const poolAddresses = await getPoolAddresses();
    poolAddresses.forEach((poolAddress) => {
        poolCoinsPromises.push(getPoolCoins(poolAddress))
        if ((nonReadablePoolAddresses.findIndex((nonReadPoolAddr) => poolAddress == nonReadPoolAddr)) == -1) {
            poolInfoPromises.push(getPoolInfo(poolAddress))
        }
    })
    const poolCoinsResult = await Promise.all(poolCoinsPromises)
    const poolInfoResult = await Promise.all(poolInfoPromises)


    data += JSON.stringify({
        poolCoins: { ...poolCoinsResult },
        poolMetadata: { ...poolInfoResult }
    })
}

const writeDataToFile = () => {
    return new Promise((resolve, reject) => {
        fs.writeFile(`${__dirname}/output/curve.json`, data, err => {
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

(async () => {
    await curveInvestmentDetails()
    await writeDataToFile()
})()