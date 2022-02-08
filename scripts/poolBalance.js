const { formatBalance, getBalanceByAdapters, decodeDerivateTokensIntoUnderlyings, getAllBalances, getFullTokenBalance } = require('./utils');
const { defiSdk } = require('./constant');

const userAddress = '0xa10d2e55f0f87756d6f99960176120c512eb3e15';

(async () => {
    const protocols = ['SushiSwap'];
    console.log('___________________________');
    // Protocol metadata
    let protocolMetaData = await defiSdk.methods.getProtocolMetadata('SushiSwap').call();
    console.log('Protocol', {
        'Name:': protocolMetaData.name,
        'Description:': protocolMetaData.description,
        'Website:': protocolMetaData.websiteURL,
        'Logo:': protocolMetaData.iconURL,
        'Version:': protocolMetaData.version
    });
    console.log('___________________________');

    console.log("User all balances are: ", JSON.stringify(await getAllBalances(userAddress), null, 4));

    console.log("User full token balance is: ", JSON.stringify(await getFullTokenBalance("Uniswap V2 pool token", "0x34d7d7Aaf50AD4944B70B320aCB24C95fa2def7c"), null, 4));
    // User balances on selected protocols or use getBalances(userAddress) for all protocols at once
    let balancesOnSelectedProtocols = await defiSdk.methods.getProtocolBalances(
        userAddress, protocols
    ).call();
    // When above call returns an empty [] array
    if (!balancesOnSelectedProtocols.length) {
        // Fetch balance by means of adapters
        await getBalanceByAdapters(protocols, ["0x34d7d7Aaf50AD4944B70B320aCB24C95fa2def7c"], userAddress)
    } else {
        // Call formatBalance to see balances in readable format
        formatBalance(balancesOnSelectedProtocols);
    }
    // Decode derivative into underlyings (Uniswap cDAI ETH as an example)
    await decodeDerivateTokensIntoUnderlyings("Uniswap V2 pool token", '0x34d7d7Aaf50AD4944B70B320aCB24C95fa2def7c')
})();