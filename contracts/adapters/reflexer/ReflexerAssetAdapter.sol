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

import {ProtocolAdapter} from "../ProtocolAdapter.sol";
import {ReflexerAdapter} from "./ReflexerAdapter.sol";
import {IGebSafeManager as GebSafeManager} from "../../interfaces/IGebSafeManager.sol";
import {ISAFEEngine as SAFEEngine} from "../../interfaces/ISAFEEngine.sol";

/**
 * @title Asset adapter for Reflexer protocol.
 * @dev Implementation of ProtocolAdapter interface.
 * @author Igor Sobolev <sobolev@zerion.io>
 */
contract ReflexerAssetAdapter is ProtocolAdapter, ReflexerAdapter {
    string public constant override adapterType = "Asset";

    string public constant override tokenType = "ERC20";

    /**
     * @return Amount of collateral locked on the protocol by the given account.
     * @dev Implementation of ProtocolAdapter interface function.
     */
    function getBalance(address token, address account)
        external
        view
        override
        returns (uint256)
    {
        GebSafeManager manager = GebSafeManager(MANAGER);
        SAFEEngine safeEngine = SAFEEngine(SAFE_ENGINE);
        uint256 id = manager.firstSAFEID(account);
        address safe;
        bytes32 collateralType;
        uint256 lockedCollateral;
        uint256 value;
        uint256 totalValue = 0;

        while (id > 0) {
            safe = manager.safes(id);
            collateralType = manager.collateralTypes(id);
            (, id) = manager.safeList(id);
            (lockedCollateral, ) = safeEngine.safes(collateralType, safe);

            if (token == WETH && collateralType == "ETH-A") {
                value = lockedCollateral;
            } else {
                value = 0;
            }

            totalValue = totalValue + value;
        }

        return totalValue;
    }
}
