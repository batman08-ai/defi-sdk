const BN = require('bignumber.js')
const { defiSdk } = require('./constant');

const getNormalizedNumber = (number, decimals) => {
    return new BN(number).dividedBy(
        new BN(10).pow(decimals)
    );
}

const formatBalance = (balancesOnSelectedProtocols) => {
    balancesOnSelectedProtocols.forEach((protocol) => {
        // The top level has protocol and adapters information
        console.log('Protocol:', protocol.metadata.name);
        protocol.adapterBalances.forEach((protocolBalances) => {
            // Each adapter could either be an Asset or Debt on the protocol
            console.log('Balance type:', protocolBalances.metadata.adapterType);
            protocolBalances.balances.forEach((balance) => {
                // Inside of each adapter there is an info about the asset and the balance
                let position = {
                    'Token': balance.base.metadata.name,
                    'Balance': getNormalizedNumber(balance.base.amount, balance.base.metadata.decimals).toString()
                };

                // If asset is a derivative then there will be underlying assets
                if (balance.underlying.length > 0) {
                    let underlying = [];
                    balance.underlying.forEach((asset) => {
                        underlying.push({
                            'Token': asset.metadata.name,
                            'Balance': getNormalizedNumber(
                                asset.amount, asset.metadata.decimals
                            ).toString()
                        })
                    });
                    position['Underlying'] = underlying
                }

                console.log('Position:', position);
            })
        })
        console.log('___________________________');
    });
}

/**
 * 
 * @param {Array} protocols An array of protocols
 * @param {Array} tokenAddresses An array of token addresses
 */
const getBalanceByAdapters = async (protocols, tokenAddresses, userAddress) => {
    for (const protocol of protocols) {
        console.log('Selected protocol is', protocol);
        const adapters = await defiSdk.methods.getProtocolAdapters(protocol).call();
        console.log("Adapters are: ", adapters);
        for (const adapter of adapters) {
            const adapterBalances = await defiSdk.methods.getAdapterBalance(userAddress, adapter, tokenAddresses).call()
            console.log("Adapter balances are: ", JSON.stringify(adapterBalances, null, 4));
        }
    }
}

/**
 * 
 * @param {String} tokenType Type of token can be { Uniswap V1 pool token OR Uniswap V2 pool token}
 * @param {String} tokenAddress ERC20 token address
 */
const decodeDerivateTokensIntoUnderlyings = async (tokenType, tokenAddress) => {
    let derivative = await defiSdk.methods.getFinalFullTokenBalance(
        tokenType,
        tokenAddress
    ).call()
    console.log('Token', derivative.base.metadata.name);

    if (derivative.underlying.length > 0) {
        let components = [];
        derivative.underlying.forEach((component) => {
            components.push(
                {
                    'Component': component.metadata.name,
                    'Amount': getNormalizedNumber(component.amount, component.metadata.decimals).toString(),
                    'Symbol': component.metadata.symbol
                }
            )
        });

        console.log('Consists of ', components);
    } else {
        console.log('Is base token');
    }
}

const getAvailableProtocols = async () => defiSdk.methods.getProtocolNames().call()

const getProtocolMetadata = async (protocol) => defiSdk.methods.getProtocolMetadata(protocol).call()

module.exports = {
    decodeDerivateTokensIntoUnderlyings,
    getAvailableProtocols,
    getBalanceByAdapters,
    getNormalizedNumber,
    getProtocolMetadata,
    formatBalance
}