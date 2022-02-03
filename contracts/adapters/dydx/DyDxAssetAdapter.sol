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

import {DyDxAdapter} from "./DyDxAdapter.sol";
import {ProtocolAdapter} from "../ProtocolAdapter.sol";
import {ISoloMargin as SoloMargin} from "../../interfaces/ISoloMargin.sol";

/**
 * @title Asset adapter for dYdX protocol.
 * @dev Implementation of ProtocolAdapter interface.
 * @author Igor Sobolev <sobolev@zerion.io>
 */
contract DyDxAssetAdapter is ProtocolAdapter, DyDxAdapter {
    string public constant override adapterType = "Asset";

    string public constant override tokenType = "ERC20";

    /**
     * @return Amount of tokens held by the given account.
     * @dev Implementation of ProtocolAdapter interface function.
     */
    function getBalance(address token, address account)
        external
        view
        override
        returns (uint256)
    {
        SoloMargin.Wei memory accountWei = SoloMargin(SOLO).getAccountWei(
            SoloMargin.Info(account, 0),
            getMarketId(token)
        );
        return accountWei.sign ? accountWei.value : 0;
    }
}
