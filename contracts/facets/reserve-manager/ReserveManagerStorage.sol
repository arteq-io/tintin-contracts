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
library ReserveManagerStorage {

    struct Layout {
        bool reservationAllowed;
        bool reservationAllowedWithoutWhitelisting;
        uint256 reservationFeeWei;
        uint256 reservePriceWeiPerToken;
        uint256 reservedTokenIdCounter;
        mapping(address => uint256) nrOfReservedTokens;
        uint256 totalNrOfReservedTokens;
        mapping(bytes32 => bytes) extra;
    }

    // Storage Slot: 4b418e6ecb487d2e2fb9a38d9cef19a8c70891b241ed0faa1758f0b03cb6547e
    bytes32 internal constant STORAGE_SLOT =
        keccak256("qomet-tech.contracts.facets.reserve-manager.storage");

    function layout() internal pure returns (Layout storage s) {
        bytes32 slot = STORAGE_SLOT;
        /* solhint-disable no-inline-assembly */
        assembly {
            s.slot := slot
        }
        /* solhint-enable no-inline-assembly */
    }
}
