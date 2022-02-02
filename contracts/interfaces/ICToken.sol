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

/**
 * @dev ICToken contract interface.
 * Only the functions required for AlphaHomoraV2TokenAdapter contract are added.
 * The ICToken contract is available here
 * github.com/compound-finance/compound-protocol/blob/master/contracts/CToken.sol.
 */
interface ICToken {
    function exchangeRateStored() external view returns (uint256);

    function isCToken() external view returns (bool);

    function borrowBalanceStored(address) external view returns (uint256);

    function borrowIndex() external view returns (uint256);

    function balanceOf(address) external view returns (uint256);

    function underlying() external view returns (address);
}
