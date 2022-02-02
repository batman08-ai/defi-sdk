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
import {ILiquidityPoolV2} from "../../interfaces/ILiquidityPoolV2.sol";
import {IKToken} from "../../interfaces/IKToken.sol";

/**
 * @title Token adapter for KTokens.
 * @dev Implementation of TokenAdapter interface.
 * @author Igor Sobolev <sobolev@zerion.io>
 */
contract KeeperDaoV2TokenAdapter is TokenAdapter {
    address internal constant POOL = 0xAaE0633E15200bc9C50d45cD762477D268E126BD;

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
        Component[] memory underlyingTokens = new Component[](1);
        address underlyingToken = IKToken(token).underlying();
        uint256 borrowableBalance = ILiquidityPoolV2(POOL).borrowableBalance(
            underlyingToken
        );

        underlyingTokens[0] = Component({
            token: underlyingToken,
            tokenType: "ERC20",
            rate: (borrowableBalance * 1e18) / ERC20(token).totalSupply()
        });

        return underlyingTokens;
    }
}
