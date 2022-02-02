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
import {MKRAdapter} from "./MKRAdapter.sol";
import {IPot} from "../../interfaces/IPot.sol";

/**
 * @title Adapter for DSR protocol.
 * @dev Implementation of ProtocolAdapter interface.
 * @author Igor Sobolev <sobolev@zerion.io>
 */
contract DSRAdapter is ProtocolAdapter, MKRAdapter {
    string public constant override adapterType = "Asset";

    string public constant override tokenType = "ERC20";

    /**
     * @return Amount of DAI locked on the protocol by the given account.
     * @dev Implementation of ProtocolAdapter interface function.
     * This function repeats the calculations made in drip() function of IPot contract.
     */
    function getBalance(address, address account)
        external
        view
        override
        returns (uint256)
    {
        IPot pot = IPot(POT);
        // solhint-disable-next-line not-rely-on-time
        uint256 chi = mkrRmul(
            mkrRpow(pot.dsr(), now - pot.rho(), ONE),
            pot.chi()
        );

        return mkrRmul(chi, pot.pie(account));
    }
}
