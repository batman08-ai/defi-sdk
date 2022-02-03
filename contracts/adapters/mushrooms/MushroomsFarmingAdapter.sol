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
import {IMasterChef as MasterChef} from "../../interfaces/IMasterChef.sol";

/**
 * @title Adapter for Mushrooms protocol (farming).
 * @dev Implementation of ProtocolAdapter interface.
 * @author Igor Sobolev <sobolev@zerion.io>
 */
contract MushroomsFarmingAdapter is ProtocolAdapter {
    string public constant override adapterType = "Asset";

    string public constant override tokenType = "ERC20";

    address internal constant MM = 0xa283aA7CfBB27EF0cfBcb2493dD9F4330E0fd304;
    address internal constant MASTER_CHEF =
        0xf8873a6080e8dbF41ADa900498DE0951074af577;

    /**
     * @return Amount of staked tokens / claimable rewards for a given account.
     * @dev Implementation of ProtocolAdapter interface function.
     */
    function getBalance(address token, address account)
        external
        view
        override
        returns (uint256)
    {
        uint256 length = MasterChef(MASTER_CHEF).poolLength();
        MasterChef.PoolInfo memory pool;

        if (token == MM) {
            uint256 totalRewards = 0;

            for (uint256 i = 0; i < length; i++) {
                totalRewards += MasterChef(MASTER_CHEF).pendingMM(i, account);
            }

            for (uint256 i = 0; i < length; i++) {
                pool = MasterChef(MASTER_CHEF).poolInfo(i);

                if (pool.lpToken == token) {
                    totalRewards += MasterChef(MASTER_CHEF)
                        .userInfo(i, account)
                        .amount;
                    break;
                }
            }

            return totalRewards;
        } else {
            for (uint256 i = 0; i < length; i++) {
                pool = MasterChef(MASTER_CHEF).poolInfo(i);

                if (pool.lpToken == token) {
                    return MasterChef(MASTER_CHEF).userInfo(i, account).amount;
                }
            }

            return 0;
        }
    }
}
