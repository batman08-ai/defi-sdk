const { curvePoolInfo } = require('../../constants')

const poolCoins = async (poolAddress) => curvePoolInfo.methods.get_pool_coins(poolAddress).call();
const poolInfo = async (poolAddress) => curvePoolInfo.methods.get_pool_info(poolAddress).call();

module.exports = {
    poolCoins,
    poolInfo
}