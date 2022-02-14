const { aaveLendingPoolV2 } = require("../../constants");

const getReservesList = async () => aaveLendingPoolV2.methods.getReservesList().call();
const getReserveData = async (asset) => aaveLendingPoolV2.methods.getReserveData(asset).call();
const getReserveNormalizedIncome = async (asset) => aaveLendingPoolV2.methods.getReserveNormalizedIncome(asset).call();
const getReserveNormalizedVariableDebt = async (asset) => aaveLendingPoolV2.methods.getReserveNormalizedVariableDebt(asset).call();
const getUserAccountData = async (userAddress) => aaveLendingPoolV2.methods.getUserAccountData(userAddress).call();

module.exports = {
    getReservesList,
    getReserveData,
    getReserveNormalizedIncome,
    getReserveNormalizedVariableDebt,
    getUserAccountData
}
