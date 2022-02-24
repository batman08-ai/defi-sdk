const { curvePoolRegistry } = require('../../constants')

const totalPools = async () => curvePoolRegistry.methods.pool_count().call()
const pool = async (poolAtIndex) => curvePoolRegistry.methods.pool_list(poolAtIndex).call()

module.exports = {
    totalPools,
    pool
}