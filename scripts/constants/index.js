const Web3 = require('web3');
const nodeUrl = 'https://mainnet.infura.io/v3/{INFURA_API_KEY}';
const ethereumNode = new Web3.providers.HttpProvider(nodeUrl)
const web3 = new Web3(ethereumNode);


const AaveProtocolDataProviderAbi = require("../contract-abis/aave-protocol-data-provider-v2.json");
const AaveProtocolDataProviderV2Address = "0x057835Ad21a177dbdd3090bB1CAE03EaCF78Fc6d"

const DeFiSdkAbi = require('../contract-abis/defi-sdk.json');
const DeFiSdkAddress = '0x06FE76B2f432fdfEcAEf1a7d4f6C3d41B5861672';

const AaveLendingPoolV2Abi = require('../contract-abis/aave-lending-pool-v2.json');
const AaveLendingPoolV2Address = '0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9';

const AaveLendingPoolV1Abi = require('../contract-abis/aave-lending-pool-v1.json');
const AaveLendingPoolV1Address = '0x398eC7346DcD622eDc5ae82352F02bE94C62d119';

const defiSdk = new web3.eth.Contract(DeFiSdkAbi, DeFiSdkAddress);
const aaveProtocolDataProvider = new web3.eth.Contract(AaveProtocolDataProviderAbi, AaveProtocolDataProviderV2Address);
const aaveLendingPoolV2 = new web3.eth.Contract(AaveLendingPoolV2Abi, AaveLendingPoolV2Address);
const aaveLendingPoolV1 = new web3.eth.Contract(AaveLendingPoolV1Abi, AaveLendingPoolV1Address);


module.exports = {
    aaveProtocolDataProvider,
    aaveLendingPoolV1,
    aaveLendingPoolV2,
    defiSdk
};
