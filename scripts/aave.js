const userAddress = '0x6cEDc25F604c7679cA159BB16f94928EbeF1473F';
const aaveProtocolDataProvider = require("./utils/aaveDataProviderV2");
const aaveLendingPoolV2 = require("./utils/aaveLendingPoolV2");
const aaveLendingPoolV1 = require("./utils/aaveLendingPoolV1");
const fs = require('fs');

let data = '';

const detailsByProtocolDataProviderV2 = async () => {
    const allATokens = await aaveProtocolDataProvider.getAllATokens();
    // console.log("All A tokens are: ", allATokens);
    const reserveTokens = await aaveProtocolDataProvider.getAllReservesTokens()
    // console.log("All reserves tokens are: ", reserveTokens);
    let reserveConfigData = [];
    let reserveData = [];
    let reserveTokenAddresses = [];
    let userReserveData = [];

    reserveTokens.forEach((reserveToken) => {
        reserveConfigData.push(aaveProtocolDataProvider.getReserveConfigurationData(reserveToken[1]));
        reserveData.push(aaveProtocolDataProvider.getReserveData(reserveToken[1]));
        reserveTokenAddresses.push(aaveProtocolDataProvider.getReserveTokensAddresses(reserveToken[1]));
        userReserveData.push(aaveProtocolDataProvider.getUserReserveData(reserveToken[1], userAddress));
    })

    const reserveConfigDataResult = await Promise.all(reserveConfigData);
    // console.log("Reserve config data result: ", reserveConfigDataResult);

    const reserveDataResult = await Promise.all(reserveData);
    // console.log("Reserve data result: ", reserveDataResult);

    const reserveTokenTokenAddrResult = await Promise.all(reserveTokenAddresses);
    // console.log("Reserve token address result: ", reserveTokenTokenAddrResult);
    // Fetches User Debt/Asset Details for BUSD
    const index = reserveTokenTokenAddrResult.findIndex((reserve) => reserve.aTokenAddress == '0xA361718326c15715591c299427c62086F69923D9');
    console.log("Found at index: ", index);

    const userReserveDataResult = await Promise.all(userReserveData);
    console.log("User reserve data result is: ", userReserveDataResult[index]);
    // console.log("User reserve data result: ", userReserveDataResult);

    data += JSON.stringify({
        protocolDataProviderV2: {
            reserveConfigData: reserveConfigDataResult,
            reserveData: reserveDataResult,
            reserveTokenAddresses: reserveTokenTokenAddrResult,
            userReserveData: userReserveDataResult
        }
    });
}

const detailsByLendingPoolV2 = async () => {
    const reservesList = await aaveLendingPoolV2.getReservesList();
    let reserveData = [];
    let reserveNormalizedIncome = [];
    let reserveNormalizedVariableDebt = [];

    reservesList.forEach((reserve) => {
        reserveData.push(aaveLendingPoolV2.getReserveData(reserve));
        reserveNormalizedIncome.push(aaveLendingPoolV2.getReserveNormalizedIncome(reserve));
        reserveNormalizedVariableDebt.push(aaveLendingPoolV2.getReserveNormalizedVariableDebt(reserve));
    })
    const reserveDataResult = await Promise.all(reserveData)
    const reserveNormalizedIncomeResult = await Promise.all(reserveNormalizedIncome)
    const reserveNormalizedVariableDebtResult = await Promise.all(reserveNormalizedVariableDebt)

    const userAccountData = await aaveLendingPoolV2.getUserAccountData(userAddress);

    data += JSON.stringify({
        lendingPoolV2: {
            reserveInformation: {
                reserveData: reserveDataResult,
                reserveNormalizedIncome: reserveNormalizedIncomeResult,
                reserveNormalizedVariableDebt: reserveNormalizedVariableDebtResult
            },
            userInformation: userAccountData
        }
    })

    console.log("Reserve data:", reserveData[index]);


    fs.writeFile('./output/aave.json', data, err => {
        if (err) {
            console.log("Error writing to file", err);
        } else {
            console.log("Written to file successfully");
        }
    })
}

const detailsByLendingPoolV1 = async () => {
    const reservesList = await aaveLendingPoolV1.getReservesList();
    let reserveData = [];
    let reserveConfigData = [];
    let userReserveData = [];

    reservesList.forEach((reserve) => {
        reserveData.push(aaveLendingPoolV1.getReserveData(reserve));
        userReserveData.push(aaveLendingPoolV1.getUserReserveData(reserve, userAddress));
        reserveConfigData.push(aaveLendingPoolV1.getReserveConfigurationData(reserve));
    })

    const reserveDataResult = await Promise.all(reserveData)
    const reserveConfigDataResult = await Promise.all(reserveConfigData)
    const userReserveDataResult = await Promise.all(userReserveData)
    const userAccountData = await aaveLendingPoolV1.getUserAccountData(userAddress);

    data += JSON.stringify({
        lendingPoolV1: {
            reserveData: reserveDataResult,
            reserveConfigData: reserveConfigDataResult,
            userReserveData: userReserveDataResult,
        },
        userInformation: userAccountData
    });

}

(async () => {
    await detailsByLendingPoolV1();
    await detailsByProtocolDataProviderV2();
    await detailsByLendingPoolV2();
})()
