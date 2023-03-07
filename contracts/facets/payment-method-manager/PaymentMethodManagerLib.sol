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

import "./PaymentMethodManagerInternal.sol";

/// @author Kam Amini <kam@arteq.io>
///
/// @notice Use at your own risk
library PaymentMethodManagerLib {

    function _handleWeiPayment(
        address payer,
        address dest,
        uint256 paidPriceWei, // could be the msg.value
        uint256 priceWeiToPay,
        string memory data
    ) internal {
        PaymentMethodManagerInternal._handleWeiPayment(
            payer,
            dest,
            paidPriceWei,
            priceWeiToPay,
            data
        );
    }

    function _handleERC20Payment(
        string memory paymentMethodName,
        address payer,
        address dest,
        uint256 priceWeiToPay,
        string memory data
    ) internal {
        PaymentMethodManagerInternal._handleERC20Payment(
            paymentMethodName,
            payer,
            dest,
            priceWeiToPay,
            data
        );
    }

    function _paymentMethodExists(
        bytes32 paymentMethodNameHash
    ) internal view returns (bool) {
        return PaymentMethodManagerLib._paymentMethodExists(paymentMethodNameHash);
    }

    function _paymentMethodEnabled(
        bytes32 paymentMethodNameHash
    ) internal view returns (bool) {
        return PaymentMethodManagerLib._paymentMethodEnabled(paymentMethodNameHash);
    }

    function _getERC20PaymentMethodAddress(
        bytes32 paymentMethodNameHash
    ) internal view returns (address) {
        return PaymentMethodManagerLib._getERC20PaymentMethodAddress(paymentMethodNameHash);
    }
}
