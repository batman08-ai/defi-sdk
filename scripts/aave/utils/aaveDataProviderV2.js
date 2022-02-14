const { aaveProtocolDataProvider } = require("../../constants");

const getAllATokens = async () => aaveProtocolDataProvider.methods.getAllATokens().call();
const getAllReservesTokens = async () => aaveProtocolDataProvider.methods.getAllReservesTokens().call();
const getReserveConfigurationData = async (asset) => aaveProtocolDataProvider.methods.getReserveConfigurationData(asset).call();
const getReserveData = async (asset) => aaveProtocolDataProvider.methods.getReserveData(asset).call();
const getReserveTokensAddresses = async (asset) => aaveProtocolDataProvider.methods.getReserveTokensAddresses(asset).call();
const getUserReserveData = async (asset, userAddress) => aaveProtocolDataProvider.methods.getUserReserveData(asset, userAddress).call();

module.exports = {
    getAllATokens,
    getAllReservesTokens,
    getReserveData,
    getReserveTokensAddresses,
    getReserveConfigurationData,
    getUserReserveData
}