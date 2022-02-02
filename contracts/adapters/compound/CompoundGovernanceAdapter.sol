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
import {IComptroller} from "../../interfaces/IComptroller.sol";

/**
 * @title Asset adapter for Compound Governance.
 * @dev Implementation of ProtocolAdapter interface.
 * @author Igor Sobolev <sobolev@zerion.io>
 */
contract CompoundGovernanceAdapter is ProtocolAdapter {
    string public constant override adapterType = "Asset";

    string public constant override tokenType = "ERC20";

    address internal constant COMPTROLLER =
        0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B;

    address internal constant COMP = 0xc00e94Cb662C3520282E6f5717214004A7f26888;

    /**
     * @return Amount of unclaimed COMP by the given account.
     * @dev Implementation of ProtocolAdapter interface function.
     */
    function getBalance(address token, address account)
        external
        view
        override
        returns (uint256)
    {
        if (token != COMP) {
            return 0;
        } else {
            uint256 balance = IComptroller(COMPTROLLER).compAccrued(account);
            address[] memory allMarkets = IComptroller(COMPTROLLER)
                .getAllMarkets();

            for (uint256 i = 0; i < allMarkets.length; i++) {
                balance += borrowerComp(account, allMarkets[i]);
                balance += supplierComp(account, allMarkets[i]);
            }

            return balance;
        }
    }

    function borrowerComp(address account, address cToken)
        internal
        view
        returns (uint256)
    {
        uint256 borrowerIndex = IComptroller(COMPTROLLER).compBorrowerIndex(
            cToken,
            account
        );

        if (borrowerIndex > 0) {
            uint256 borrowIndex = uint256(
                IComptroller(COMPTROLLER).compBorrowState(cToken).index
            );
            require(borrowIndex >= borrowerIndex, "CGA: underflow!");
            uint256 deltaIndex = borrowIndex - borrowerIndex;
            uint256 borrowerAmount = mul(
                ICToken(cToken).borrowBalanceStored(account),
                1e18
            ) / ICToken(cToken).borrowIndex();
            uint256 borrowerDelta = mul(borrowerAmount, deltaIndex) / 1e36;
            return borrowerDelta;
        } else {
            return 0;
        }
    }

    function supplierComp(address account, address cToken)
        internal
        view
        returns (uint256)
    {
        uint256 supplierIndex = IComptroller(COMPTROLLER).compSupplierIndex(
            cToken,
            account
        );
        uint256 supplyIndex = uint256(
            IComptroller(COMPTROLLER).compSupplyState(cToken).index
        );
        if (supplierIndex == 0 && supplyIndex > 0) {
            supplierIndex = 1e36;
        }
        require(supplyIndex >= supplierIndex, "CGA: underflow!");
        uint256 deltaIndex = supplyIndex - supplierIndex;
        uint256 supplierAmount = ICToken(cToken).balanceOf(account);
        uint256 supplierDelta = mul(supplierAmount, deltaIndex) / 1e36;

        return supplierDelta;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "CGA: mul overflow");

        return c;
    }
}
