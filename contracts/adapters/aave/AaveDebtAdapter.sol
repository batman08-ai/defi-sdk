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
import {ILendingPool} from "../../interfaces/ILendingPool.sol";
import {ILendingPoolAddressesProvider} from "../../interfaces/ILendingPoolAddressesProvider.sol";

/**
 * @title Debt adapter for Aave protocol.
 * @dev Implementation of ProtocolAdapter interface.
 * @author Igor Sobolev <sobolev@zerion.io>
 */
contract AaveDebtAdapter is ProtocolAdapter {
    address internal constant PROVIDER =
        0x24a42fD28C976A61Df5D00D0599C34c4f90748c8;

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
        ILendingPool pool = ILendingPoolAddressesProvider(PROVIDER)
            .getLendingPool();

        (, uint256 debtAmount) = pool.getUserReserveData(token, account);

        return debtAmount;
    }
}
