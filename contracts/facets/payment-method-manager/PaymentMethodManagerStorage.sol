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
library PaymentMethodManagerStorage {

    struct ERC20PaymentMethod {
        // The internal unique name of the ERC-20 payment method
        string name;
        // The ERC-20 contract
        address erc20;
        // Uniswap V2 Pair with WETH
        address wethPair;
        // True if the read pair from Uniswap has a reverse ordering
        // for contract addresses
        bool reverseIndices;
        // If the payment method is enabled
        bool enabled;
    }

    struct Layout {
        // The WETH ERC-20 contract address.
        //   On mainnet, it is: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
        address wethAddress;
        // The list of the existing ERC20 payment method names
        string[] erc20PaymentMethodNames;
        mapping(string => uint256)  erc20PaymentMethodNamesIndex;
        // name > erc20 payment method
        mapping(bytes32 => ERC20PaymentMethod) erc20PaymentMethods;
        // Reserved for future upgrades
        mapping(bytes32 => bytes) extra;
    }

    // Storage Slot: 24fec23af2e4f32093ca891ed8523f1a3b1e830e40b644a114ae877ef9d833ad
    bytes32 internal constant STORAGE_SLOT =
        keccak256("qomet-tech.contracts.facets.payment-method-manager.storage");

    function layout() internal pure returns (Layout storage s) {
        bytes32 slot = STORAGE_SLOT;
        /* solhint-disable no-inline-assembly */
        assembly {
            s.slot := slot
        }
        /* solhint-enable no-inline-assembly */
    }
}
