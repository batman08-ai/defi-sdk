// Copyright (C) 2020 Zerion Inc. <https://zerion.io>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.

pragma solidity 0.6.5;
pragma experimental ABIEncoderV2;

import {ERC20} from "../../ERC20.sol";
import {TokenMetadata, Component} from "../../Structs.sol";
import {TokenAdapter} from "../TokenAdapter.sol";
import {IBancorConverter} from "../../interfaces/IBancorConverter.sol";
import {ISmartToken} from "../../interfaces/ISmartToken.sol";
import {IContractRegistry} from "../../interfaces/IContractRegistry.sol";
import {IBancorFormula} from "../../interfaces/IBancorFormula.sol";

/**
 * @title Token adapter for SmartTokens.
 * @dev Implementation of TokenAdapter interface.
 * @author Igor Sobolev <sobolev@zerion.io>
 */
contract BancorTokenAdapter is TokenAdapter {
    address internal constant REGISTRY =
        0x52Ae12ABe5D8BD778BD5397F99cA900624CfADD4;
    address internal constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    /**
     * @return TokenMetadata struct with ERC20-style token info.
     * @dev Implementation of TokenAdapter interface function.
     */
    function getMetadata(address token)
        external
        view
        override
        returns (TokenMetadata memory)
    {
        return
            TokenMetadata({
                token: token,
                name: ERC20(token).name(),
                symbol: ERC20(token).symbol(),
                decimals: ERC20(token).decimals()
            });
    }

    /**
     * @return Array of Component structs with underlying tokens rates for the given token.
     * @dev Implementation of TokenAdapter interface function.
     */
    function getComponents(address token)
        external
        view
        override
        returns (Component[] memory)
    {
        address formula = IContractRegistry(REGISTRY).addressOf("BancorFormula");
        uint256 totalSupply = ISmartToken(token).totalSupply();
        address converter = ISmartToken(token).owner();
        uint256 connectorTokenCount = IBancorConverter(converter)
            .connectorTokenCount();

        Component[] memory underlyingTokens = new Component[](
            connectorTokenCount
        );

        address underlyingToken;
        uint256 balance;
        for (uint256 i = 0; i < connectorTokenCount; i++) {
            underlyingToken = IBancorConverter(converter).connectorTokens(i);

            if (underlyingToken == ETH) {
                balance = converter.balance;
            } else {
                balance = ERC20(underlyingToken).balanceOf(converter);
            }

            underlyingTokens[i] = Component({
                token: underlyingToken,
                tokenType: "ERC20",
                rate: IBancorFormula(formula).calculateLiquidateReturn(
                    totalSupply,
                    balance,
                    uint32(1000000),
                    uint256(1e18)
                )
            });
        }

        return underlyingTokens;
    }
}
