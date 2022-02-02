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

/**
 * @dev IVat contract interface.
 * Only the functions required for MCDDebtAdapter contract are added.
 * The IVat contract is available here
 * github.com/makerdao/dss/blob/master/src/vat.sol.
 */
interface IVat {
    function urns(bytes32, address) external view returns (uint256, uint256);

    function ilks(bytes32) external view returns (uint256, uint256);
}

/**
 * @dev IJug contract interface.
 * Only the functions required for MCDDebtAdapter contract are added.
 * The IJug contract is available here
 * github.com/makerdao/dss/blob/master/src/jug.sol.
 */
interface IJug {
    function ilks(bytes32) external view returns (uint256, uint256);

    function base() external view returns (uint256);
}

/**
 * @dev IDssCdpManager contract interface.
 * Only the functions required for MCDDebtAdapter contract are added.
 * The IDssCdpManager contract is available here
 * github.com/makerdao/dss-cdp-manager/blob/master/src/DssCdpManager.sol.
 */
interface IDssCdpManager {
    function first(address) external view returns (uint256);

    function list(uint256) external view returns (uint256, uint256);

    function urns(uint256) external view returns (address);

    function ilks(uint256) external view returns (bytes32);
}

/**
 * @title Debt adapter for MCD protocol.
 * @dev Implementation of ProtocolAdapter interface.
 * @author Igor Sobolev <sobolev@zerion.io>
 */
contract MCDDebtAdapter is ProtocolAdapter, MKRAdapter {
    string public constant override adapterType = "Debt";

    string public constant override tokenType = "ERC20";

    /**
     * @return Amount of debt of the given account for the protocol.
     * @dev Implementation of ProtocolAdapter interface function.
     */
    function getBalance(address, address account)
        external
        view
        override
        returns (uint256)
    {
        IDssCdpManager manager = IDssCdpManager(MANAGER);
        IVat vat = IVat(VAT);
        IJug jug = IJug(JUG);
        uint256 id = manager.first(account);
        uint256 totalValue = 0;

        while (id > 0) {
            bytes32 ilk = manager.ilks(id);
            (, id) = manager.list(id);
            (, uint256 art) = vat.urns(ilk, manager.urns(id));
            (, uint256 storedRate) = vat.ilks(ilk);
            (uint256 duty, uint256 rho) = jug.ilks(ilk);
            uint256 base = jug.base();
            // solhint-disable-next-line not-rely-on-time
            uint256 currentRate = mkrRmul(
                mkrRpow(mkrAdd(base, duty), now - rho, ONE),
                storedRate
            );

            totalValue = totalValue + mkrRmul(art, currentRate);
        }

        return totalValue;
    }
}
