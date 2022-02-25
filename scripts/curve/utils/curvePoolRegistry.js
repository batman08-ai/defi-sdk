const { curvePoolRegistry } = require('../../constants')

const totalPools = async () => curvePoolRegistry.methods.pool_count().call()
const pool = async (poolAtIndex) => curvePoolRegistry.methods.pool_list(poolAtIndex).call()
const rates = async (poolAddress) => curvePoolRegistry.methods.get_rates(poolAddress).call()
const balances = async (poolAddress) => curvePoolRegistry.methods.get_balances(poolAddress).call()
const underlyingBalances = async (poolAddress) => curvePoolRegistry.methods.get_underlying_balances(poolAddress).call()
const getLPToken = async (poolAddress) => curvePoolRegistry.methods.get_lp_token(poolAddress).call()

module.exports = {
    totalPools,
    pool,
    rates,
    balances,
    underlyingBalances,
    getLPToken
}