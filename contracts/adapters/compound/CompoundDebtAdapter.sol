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
import {ProtocolAdapter} from "../ProtocolAdapter.sol";
import {ICToken} from "../../interfaces/ICToken.sol";
import {ICompoundRegistry as CompoundRegistry} from "../../interfaces/ICompoundRegistry.sol";

/**
 * @title Debt adapter for Compound protocol.
 * @dev Implementation of ProtocolAdapter interface.
 * @author Igor Sobolev <sobolev@zerion.io>
 */
contract CompoundDebtAdapter is ProtocolAdapter {
    address internal constant REGISTRY =
        0x745eC6C92E3Fa2Ac470B3323128c6ad2eAB21d67;

    string public constant override adapterType = "Debt";

    string public constant override tokenType = "ERC20";

    /**
     * @return Amount of debt of the given account for the protocol.
     * @dev Implementation of ProtocolAdapter interface function.
     */
    function getBalance(address token, address account)
        external
        view
        override
        returns (uint256)
    {
        address cToken = CompoundRegistry(REGISTRY).getCToken(token);

        return ICToken(cToken).borrowBalanceStored(account);
    }
}
