const defiSdk = require('./utils/defiSdk');

const userAddress = '0xD965952823153E5CBc611be87e8322cfc329f056';
const tokenAddress = '0xdac17f958d2ee523a2206206994597c13d831ec7';

(async () => {
    const protocolNames = ["Compound", "Curve", "Aave", "Balancer", "Bancor"];

    /*console.log('___________________________');
    // Protocol metadata
    for (const protocol of protocols) {
        const protocolMetaData = await defiSdk.getProtocolMetadata(protocol);
        console.log('Protocol', {
            'Name:': protocolMetaData.name,
            'Description:': protocolMetaData.description,
            'Website:': protocolMetaData.websiteURL,
            'Logo:': protocolMetaData.iconURL,
            'Version:': protocolMetaData.version
        });
    }
    console.log('___________________________');*/

    const allBalance = await defiSdk.getAllBalances(userAddress);
    console.log("All balance of the user: ", allBalance);

    console.log('_________________________________________________________________________________');

    const protocolBalances = await defiSdk.getProtocolBalances(userAddress, protocolNames);
    console.log("Protocol balance of the user: ", protocolBalances);

    console.log('_________________________________________________________________________________');

    if (protocolBalances.length) {
        defiSdk.formatBalance(protocolBalances)
    }

    console.log('_________________________________________________________________________________');

    /**
     * Get balance by adapters
     */
    for (const protocol of protocolNames) {
        console.log("Fetching balance by adapter for protocol: ", protocol);
        const adapters = await defiSdk.protocolAdapters(protocol);
        console.log("adapters are: ", adapters);
        for (const adapter of adapters) {
            console.log("Adapter is: ", adapter);
            let suppoTokens = await defiSdk.supportedTokens(adapter);
            const tokenAddresses = [...suppoTokens, tokenAddress]
            const adapterBal = await defiSdk.adapterBalance(userAddress, adapter, tokenAddresses)
            console.log("Adapter balance of the user: ", JSON.stringify(adapterBal, null, 4));
        }
        /*const adapterBal = await defiSdk.adapterBalances(userAddress, adapters)
        console.log("Adapter balance of the user: ", JSON.stringify(adapterBal, null, 4));*/
    }
    console.log('_________________________________________________________________________________');
    if (allBalance.length) {
        defiSdk.formatBalance(allBalance)
    }
})();