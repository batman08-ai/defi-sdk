const BancorSmartToken = require('../../contract-abis/bancor-smart-token.json');
const { getBancorContracts } = require('../../constants');

const balanceOf = async (userAddress, contractAddress) => {
    const contract = getBancorContracts(BancorSmartToken, contractAddress);
    const balance = await contract.methods.balanceOf(userAddress).call();
    return balance;
}

module.exports = {
    balanceOf
}