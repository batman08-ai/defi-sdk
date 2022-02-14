const { aaveLendingPoolV1 } = require("../../constants");

const getReservesList = async () => aaveLendingPoolV1.methods.getReserves().call();
const getReserveData = async (asset) => aaveLendingPoolV1.methods.getReserveData(asset).call();
const getUserAccountData = async (userAddress) => aaveLendingPoolV1.methods.getUserAccountData(userAddress).call();
const getUserReserveData = async (asset, userAddress) => aaveLendingPoolV1.methods.getUserReserveData(asset, userAddress).call();
const getReserveConfigurationData = async (asset) => aaveLendingPoolV1.methods.getReserveConfigurationData(asset).call();

module.exports = {
    getReservesList,
    getReserveData,
    getUserAccountData,
    getUserReserveData,
    getReserveConfigurationData
}
