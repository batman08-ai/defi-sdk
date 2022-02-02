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

/**
 * @title Token adapter for SmartTokens.
 * @dev Implementation of TokenAdapter interface.
 * @author Igor Sobolev <sobolev@zerion.io>
 */
contract BancorV21TokenAdapter is TokenAdapter {
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
        address converter = ISmartToken(token).owner();
        address[] memory reserveTokens = IBancorConverter(converter)
            .reserveTokens();
        uint256[] memory rates = IBancorConverter(converter)
            .removeLiquidityReturn(1e18, reserveTokens);

        uint256 length = reserveTokens.length;
        Component[] memory underlyingTokens = new Component[](length);

        for (uint256 i = 0; i < length; i++) {
            underlyingTokens[i] = Component({
                token: reserveTokens[i],
                tokenType: "ERC20",
                rate: rates[i]
            });
        }

        return underlyingTokens;
    }
}
