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
 * @dev IStakingRewards contract interface.
 * Only the functions required for AragonStakingAdapter contract are added.
 * The IStakingRewards contract is available here
 * github.com/Synthetixio/synthetix/blob/master/contracts/StakingRewards.sol.
 */
interface IStakingRewards {
    function earned(address) external view returns (uint256);

    function earned(address, uint256) external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);
}
