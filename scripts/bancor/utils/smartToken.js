const BancorSmartToken = require('../../contract-abis/bancor-smart-token.json');
const { getContractFromABIAndAddress } = require('../../constants');

const balanceOf = async (userAddress, contractAddress) => {
    const contract = getContractFromABIAndAddress(BancorSmartToken, contractAddress);
    const balance = await contract.methods.balanceOf(userAddress).call();
    return balance;
}

module.exports = {
    balanceOf
}