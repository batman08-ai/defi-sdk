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
/**
 * @dev CompMarketState contract interface.
 * Only the functions required for CompoundGovernanceAdapter contract are added.
 * The CompMarketState struct is available here
 * github.com/compound-finance/compound-protocol/blob/master/contracts/ComptrollerStorage.sol.
 */
struct CompMarketState {
    uint224 index;
    uint32 block;
}

/**
 * @dev Comptroller contract interface.
 * Only the functions required for CompoundGovernanceAdapter contract are added.
 * The Comptroller contract is available here
 * github.com/compound-finance/compound-protocol/blob/master/contracts/Comptroller.sol.
 */
interface IComptroller {
    function getAllMarkets() external view returns (address[] memory);

    function compBorrowState(address)
        external
        view
        returns (CompMarketState memory);

    function compSupplyState(address)
        external
        view
        returns (CompMarketState memory);

    function compBorrowerIndex(address, address)
        external
        view
        returns (uint256);

    function compSupplierIndex(address, address)
        external
        view
        returns (uint256);

    function compAccrued(address) external view returns (uint256);
}
