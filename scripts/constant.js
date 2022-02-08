const Web3 = require('web3');
const DeFiSdkAbi = require('./defi-sdk-abi');
const DeFiSdkAddress = '0x06FE76B2f432fdfEcAEf1a7d4f6C3d41B5861672';
const nodeUrl = 'https://mainnet.infura.io/v3/275873b9f431493a89153738398abf2a';
const ethereumNode = new Web3.providers.HttpProvider(nodeUrl)
const web3 = new Web3(ethereumNode);
const defiSdk = new web3.eth.Contract(DeFiSdkAbi, DeFiSdkAddress);

const getDefiSDK = () => defiSdk

module.exports = {
    defiSdk
}