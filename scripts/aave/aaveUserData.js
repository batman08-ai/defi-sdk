const fs = require('fs');

const userAddress = '0x6cEDc25F604c7679cA159BB16f94928EbeF1473F';
const aaveProtocolDataProvider = require("./utils/aaveDataProviderV2");
const aaveLendingPoolV2 = require("./utils/aaveLendingPoolV2");
const aaveLendingPoolV1 = require("./utils/aaveLendingPoolV1");
const AaveTokenAddresses = require("./utils/aaveTokenAddresses.json");
//TODO @Ashish & Amrutanshoo will fetch the token name, symbol, decimals from these AaveTokenAddresses JSON object
let data = '';

const detailsByProtocolDataProviderV2 = async () => {
    const reserveTokens = await aaveProtocolDataProvider.getAllReservesTokens()
    let userReserveData = [];
    let reserveTokenAddresses = [];
    let userDataProtocolDataProviderV2 = [];

    reserveTokens.forEach((reserveToken) => {
        reserveTokenAddresses.push(aaveProtocolDataProvider.getReserveTokensAddresses(reserveToken[1]));
        userReserveData.push(aaveProtocolDataProvider.getUserReserveData(reserveToken[1], userAddress));
    })

    const reserveTokenTokenAddrResult = await Promise.all(reserveTokenAddresses);

    const userReserveDataResult = await Promise.all(userReserveData);
    /**
     * Inside forEach the response for user data is formatted
     */
    userReserveDataResult.forEach((userResData, index) => {
        const {
            currentATokenBalance, currentStableDebt, currentVariableDebt, principalStableDebt,
            scaledVariableDebt, stableBorrowRate, liquidityRate, stableRateLastUpdated, usageAsCollateralEnabled
        } = userResData;

        if (currentATokenBalance != 0 || currentStableDebt != 0 || currentVariableDebt != 0 || principalStableDebt != 0 || scaledVariableDebt != 0 || stableBorrowRate != 0) {
            const { aTokenAddress, stableDebtTokenAddress, variableDebtTokenAddress } = reserveTokenTokenAddrResult[index];
            //TODO @Ashish OR @Amrutanshoo use aTokenAddress and do the traversing of AaveTokenAddresses JSON to get token name, symbol, decimals and other required token metadata
            userDataProtocolDataProviderV2.push({
                token: {
                    aTokenAddress,
                    stableDebtTokenAddress,
                    variableDebtTokenAddress
                },
                currentATokenBalance,
                currentStableDebt,
                currentVariableDebt,
                principalStableDebt,
                scaledVariableDebt,
                stableBorrowRate,
                liquidityRate,
                stableRateLastUpdated,
                usageAsCollateralEnabled
            });
        }
    })
    // console.log("User data by data protocol provider V2: ", userDataProtocolDataProviderV2);

    data += JSON.stringify({
        protocolDataProviderV2: {
            data: userDataProtocolDataProviderV2
        }
    });
}

const detailsByLendingPoolV2 = async () => {
    const userAccountData = await aaveLendingPoolV2.getUserAccountData(userAddress);
    const { totalCollateralETH, totalDebtETH, availableBorrowsETH, currentLiquidationThreshold, ltv, healthFactor } = userAccountData;
    const userData = {
        totalCollateralETH,
        totalDebtETH,
        availableBorrowsETH,
        currentLiquidationThreshold,
        ltv,
        healthFactor
    };
    // console.log("User data by lending pool V2: ", userData);
    data += JSON.stringify({
        lendingPoolV2: {
            data: [userData]
        }
    })
}

const detailsByLendingPoolV1 = async () => {
    const reservesList = await aaveLendingPoolV1.getReservesList();
    let reserveData = [];
    let userReserveData = [];
    let lendingPoolDataV1 = [];

    reservesList.forEach((reserve) => {
        reserveData.push(aaveLendingPoolV1.getReserveData(reserve));
        userReserveData.push(aaveLendingPoolV1.getUserReserveData(reserve, userAddress));
    })

    const reserveDataResult = await Promise.all(reserveData)
    const userReserveDataResult = await Promise.all(userReserveData)
    const userAccountData = await aaveLendingPoolV1.getUserAccountData(userAddress);

    const { totalLiquidityETH, totalCollateralETH, totalBorrowsETH, totalFeesETH, availableBorrowsETH, currentLiquidationThreshold, ltv, healthFactor } = userAccountData;
    const userData = { totalLiquidityETH, totalCollateralETH, totalBorrowsETH, totalFeesETH, availableBorrowsETH, currentLiquidationThreshold, ltv, healthFactor };

    userReserveDataResult.forEach((userResData, index) => {
        const { currentATokenBalance, currentBorrowBalance, principalBorrowBalance, borrowRateMode, borrowRate, liquidityRate, originationFee, variableBorrowIndex, lastUpdateTimestamp, usageAsCollateralEnabled } = userResData;

        const { totalLiquidity, availableLiquidity, totalBorrowsStable, totalBorrowsVariable, liquidityRate: liqRate, variableBorrowRate, stableBorrowRate, averageStableBorrowRate, utilizationRate, liquidityIndex, variableBorrowIndex: varBorrowIndex, aTokenAddress, lastUpdateTimestamp: lUTimestamp } = reserveDataResult[index];

        if (currentATokenBalance != 0 || currentBorrowBalance != 0 || principalBorrowBalance != 0) {
            lendingPoolDataV1.push({
                token: {
                    totalLiquidity, availableLiquidity, totalBorrowsStable, totalBorrowsVariable, liquidityRate: liqRate, variableBorrowRate, stableBorrowRate, averageStableBorrowRate, utilizationRate, liquidityIndex, variableBorrowIndex: varBorrowIndex, aTokenAddress, lastUpdateTimestamp: lUTimestamp
                },
                currentATokenBalance, currentBorrowBalance, principalBorrowBalance, borrowRateMode, borrowRate, liquidityRate, originationFee, variableBorrowIndex, lastUpdateTimestamp, usageAsCollateralEnabled
            })
        }
    })

    // console.log("LendingPoolV1: ", lendingPoolDataV1, "\nUser data: ", userData);

    data += JSON.stringify({
        lendingPoolV1: {
            data: lendingPoolDataV1,
            userData
        },
    });
}

const writeDataToFile = () => {
    return new Promise((resolve, reject) => {
        fs.writeFile(`${__dirname}/output/aaveUser.json`, data, err => {
            if (err) {
                console.log("Error writing to file", err);
                reject(err);
            } else {
                console.log("Written to file successfully");
                resolve("Written to file successfully")
            }
        })
    })
}

(
    async () => {
        await detailsByProtocolDataProviderV2();
        await detailsByLendingPoolV2();
        await detailsByLendingPoolV1();
        await writeDataToFile();
    }
)()