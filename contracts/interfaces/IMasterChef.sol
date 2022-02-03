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
 * @dev MasterChef contract interface.
 * Only the functions required for MushroomsFarmingAdapter contract are added.
 * The MasterChef contract is available (verified and open-sourced) at
 * https://etherscan.io/address/0xf8873a6080e8dbf41ada900498de0951074af577
 */
interface IMasterChef {
    /**
     * @dev UserInfo struct from MasterChef contract.
     * The MasterChef contract is available (verified and open-sourced) at
     * https://etherscan.io/address/0xf8873a6080e8dbf41ada900498de0951074af577
     */
    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    /**
     * @dev PoolInfo struct from MasterChef contract.
     * The MasterChef contract is available (verified and open-sourced) at
     * https://etherscan.io/address/0xf8873a6080e8dbf41ada900498de0951074af577
     */
    struct PoolInfo {
        address lpToken;
        uint256 allocPoint;
        uint256 lastRewardBlock;
        uint256 accSushiPerShare;
        uint256 amount;
    }

    function poolLength() external view returns (uint256);

    function poolInfo(uint256) external view returns (PoolInfo memory);

    function userInfo(uint256, address) external view returns (UserInfo memory);

    function pendingMM(uint256, address) external view returns (uint256);

    function pendingSushi(uint256, address) external view returns (uint256);

    function pendingPickle(uint256, address) external view returns (uint256);

    function pendingSashimi(uint256, address) external view returns (uint256);
}
