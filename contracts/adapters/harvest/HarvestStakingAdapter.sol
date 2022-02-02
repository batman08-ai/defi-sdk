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
import {Ownable} from "../../Ownable.sol";
import {IStakingRewards} from "../../interfaces/IStakingRewards.sol";

struct Pool {
    address poolAddress;
    address stakingToken;
    address rewardToken;
}

/**
 * @title Adapter for Harvest protocol.
 * @dev Implementation of ProtocolAdapter interface.
 * @author Igor Sobolev <sobolev@zerion.io>
 */
contract HarvestStakingAdapter is ProtocolAdapter, Ownable {
    string public constant override adapterType = "Asset";

    string public constant override tokenType = "ERC20";

    // Returns if the pool is enabled
    mapping(address => bool) internal isEnabledPool_;
    // Returns the list of pools where the given token is a staking token
    mapping(address => address[]) internal stakingPools_;
    // Returns the list of pools where the given token is a reward token
    mapping(address => address[]) internal rewardPools_;

    event PoolAdded(
        address indexed poolAddress,
        address indexed stakingToken,
        address indexed rewardToken
    );

    function addPools(Pool[] calldata pools) external onlyOwner {
        uint256 length = pools.length;

        for (uint256 i = 0; i < length; i++) {
            addPool(pools[i]);
        }
    }

    function setIsEnabledPools(
        address[] calldata poolAddresses,
        bool[] calldata isEnabledPools
    ) external onlyOwner {
        uint256 length = poolAddresses.length;
        require(isEnabledPools.length == length, "HSA: inconsistent arrays");

        for (uint256 i = 0; i < length; i++) {
            setIsEnabledPool(poolAddresses[i], isEnabledPools[i]);
        }
    }

    /**
     * @return Amount of staked tokens / rewards earned after staking for a given account.
     * @dev Implementation of ProtocolAdapter interface function.
     */
    function getBalance(address token, address account)
        external
        view
        override
        returns (uint256)
    {
        address[] memory stakingPools = stakingPools_[token];
        address[] memory rewardPools = rewardPools_[token];

        uint256 length;
        uint256 totalBalance = 0;

        length = stakingPools.length;
        for (uint256 i = 0; i < length; i++) {
            totalBalance += getStakingBalance(stakingPools[i], account);
        }

        length = rewardPools.length;
        for (uint256 i = 0; i < length; i++) {
            totalBalance += getRewardBalance(rewardPools[i], account);
        }

        return totalBalance;
    }

    function getRewardPools(address token)
        external
        view
        returns (address[] memory)
    {
        return rewardPools_[token];
    }

    function getStakingPools(address token)
        external
        view
        returns (address[] memory)
    {
        return stakingPools_[token];
    }

    function addPool(Pool memory pool) internal {
        stakingPools_[pool.stakingToken].push(pool.poolAddress);
        rewardPools_[pool.rewardToken].push(pool.poolAddress);
        setIsEnabledPool(pool.poolAddress, true);

        emit PoolAdded(pool.poolAddress, pool.stakingToken, pool.rewardToken);
    }

    function setIsEnabledPool(address poolAddress, bool isEnabledPool)
        internal
    {
        isEnabledPool_[poolAddress] = isEnabledPool;
    }

    function getRewardBalance(address poolAddress, address account)
        internal
        view
        returns (uint256)
    {
        return
            isEnabledPool_[poolAddress]
                ? IStakingRewards(poolAddress).earned(account)
                : 0;
    }

    function getStakingBalance(address poolAddress, address account)
        internal
        view
        returns (uint256)
    {
        return
            isEnabledPool_[poolAddress]
                ? ERC20(poolAddress).balanceOf(account)
                : 0;
    }
}
