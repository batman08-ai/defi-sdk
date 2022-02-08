const { formatBalance, getBalanceByAdapters, decodeDerivateTokensIntoUnderlyings, getAvailableProtocols, getProtocolMetadata } = require('./utils');
const { defiSdk } = require('./constant');

const userAddress = '0x42b9dF65B219B3dD36FF330A4dD8f327A6Ada990';
const tokenAddress = '0x34E89740adF97C3A9D3f63Cc2cE4a914382c230b';


(async () => {
    const protocols = ['Aave', 'Compound', 'Synthetix', 'PoolTogether', 'SushiSwap'];

    // List of available protocols
    let protocolNames = await getAvailableProtocols();
    console.log('Available protocols names are', protocolNames);

    console.log('___________________________');
    // Protocol metadata
    for (const protocol of protocols) {
        let protocolMetaData = await getProtocolMetadata(protocol);
        console.log('Protocol', {
            'Name:': protocolMetaData.name,
            'Description:': protocolMetaData.description,
            'Website:': protocolMetaData.websiteURL,
            'Logo:': protocolMetaData.iconURL,
            'Version:': protocolMetaData.version
        });
    }
    console.log('___________________________');

    // User balances on selected protocols or use getBalances(userAddress) for all protocols at once
    let balancesOnSelectedProtocols = await defiSdk.methods.getProtocolBalances(
        userAddress, ['Aave', 'Compound', 'Synthetix', 'PoolTogether', 'SushiSwap']
    ).call();

    if (!balancesOnSelectedProtocols.length) {
        // Fetch balance by means of adapters
        await getBalanceByAdapters(protocols, [tokenAddress], userAddress)
    } else {
        formatBalance(balancesOnSelectedProtocols);
    }
    // Decode derivative into underlyings (Uniswap cDAI ETH as an example)
    await decodeDerivateTokensIntoUnderlyings("Uniswap V1 pool token", tokenAddress)
})();



