/*
 * This file is part of the Qomet Technologies contracts (https://github.com/qomet-tech/contracts).
 * Copyright (c) 2022 Qomet Technologies (https://qomet.tech)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
// SPDX-License-Identifier: GNU General Public License v3.0

pragma solidity 0.8.1;

import "../reserve-manager/ReserveManagerLib.sol";
import "./CrossmintStorage.sol";

library CrossmintInternal {

    function _getCrossmintSettings() internal view returns (bool, address) {
        return (__s().crossmintEnabled, __s().crossmintTrustedAddress);
    }

    function _setCrossmintSettings(
        bool crossmintEnabled,
        address crossmintTrustedAddress
    ) internal {
        __s().crossmintEnabled = crossmintEnabled;
        __s().crossmintTrustedAddress = crossmintTrustedAddress;
    }

    function _crossmintReserve(address to, uint256 nrOfTokens) internal {
        require(__s().crossmintEnabled, "CMI:NE");
        require(msg.sender == __s().crossmintTrustedAddress, "CMI:IC");
        ReserveManagerLib._reserveForAccount(to, nrOfTokens, "WEI");
    }

    function __s() private pure returns (CrossmintStorage.Layout storage) {
        return CrossmintStorage.layout();
    }
}
