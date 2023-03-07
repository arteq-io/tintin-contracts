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
library RoyaltyManagerStorage {

    struct TokenRoyaltyInfo {
        address royaltyWallet;
        uint256 royaltyPercentage;
        bool exempt;
    }

    struct Layout {
        address defaultRoyaltyWallet;
        uint256 defaultRoyaltyPercentage;
        mapping(uint256 => TokenRoyaltyInfo) tokenRoyalties;
        mapping(bytes32 => bytes) extra;
    }

    // Storage Slot: 30dd8d77605a814c64262f14d377f6fb38cece608fcff2bdb5990cc0e7b041a1
    bytes32 internal constant STORAGE_SLOT =
        keccak256("qomet-tech.contracts.facets.royalty-manager.storage");

    function layout() internal pure returns (Layout storage s) {
        bytes32 slot = STORAGE_SLOT;
        /* solhint-disable no-inline-assembly */
        assembly {
            s.slot := slot
        }
        /* solhint-enable no-inline-assembly */
    }
}
