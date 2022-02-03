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
 * @dev GebSafeManager contract interface.
 * Only the functions required for ReflexerAssetAdapter contract are added.
 * The GebSafeManager contract is available here
 * github.com/reflexer-labs/geb-safe-manager/blob/master/src/GebSafeManager.sol.
 */
interface IGebSafeManager {
    function firstSAFEID(address) external view returns (uint256);

    function safeList(uint256) external view returns (uint256, uint256);

    function safes(uint256) external view returns (address);

    function collateralTypes(uint256) external view returns (bytes32);
}
