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

/// @author Kam Amini <kam@arteq.io>
///
/// @notice Use at your own risk. Just got the basic
///         idea from: https://github.com/solidstate-network/solidstate-solidity
library WhitelistManagerStorage {

    struct Layout {
        bool whitelistingAllowed;
        uint256 whitelistingFeeWei;
        uint256 whitelistingPriceWeiPerToken;
        uint256 maxNrOfWhitelistedTokensPerAccount;
        mapping(address => uint256) whitelistEntries;
        uint256 totalNrOfWhitelists;
        mapping(bytes32 => bytes) extra;
    }

    // Storage Slot: 8f148433202b4f27178e65c12a3cdee0fa9a268e10843848150d8183da0b4c8a
    bytes32 internal constant STORAGE_SLOT =
        keccak256("qomet-tech.contracts.facets.whitelist-manager.storage");

    function layout() internal pure returns (Layout storage s) {
        bytes32 slot = STORAGE_SLOT;
        /* solhint-disable no-inline-assembly */
        assembly {
            s.slot := slot
        }
        /* solhint-enable no-inline-assembly */
    }
}
