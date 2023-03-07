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

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "../IUniswapV2Pair.sol";
import "./PaymentMethodManagerStorage.sol";

/// @author Kam Amini <kam@arteq.io>
///
/// @notice Use at your own risk
library PaymentMethodManagerInternal {

    event ERC20PaymentMethodUpdate(
        string paymentMethodName,
        address erc20,
        address wethPair,
        bool enabled,
        string data
    );
    event WeiPayment(
        address payer,
        address dest,
        uint256 paidPriceWei,
        uint256 priceWeiToPay,
        string data
    );
    event ERC20Payment(
        string paymentMethodName,
        address payer,
        address dest,
        uint256 amountWei,
        uint256 amountTokens,
        string data
    );

    function _getPaymentMethodManagerSettings() internal view returns (address) {
        return __s().wethAddress;
    }

    function _setPaymentMethodManagerSettings(
        address wethAddress
    ) internal {
        __s().wethAddress = wethAddress;
    }

    function _getERC20PaymentMethods() internal view returns (string[] memory) {
        return __s().erc20PaymentMethodNames;
    }

    function _getERC20PaymentMethod(
        string memory paymentMethodName
    ) internal view returns (address, address, bool) {
        bytes32 nameHash = keccak256(abi.encode(paymentMethodName));
        require(_paymentMethodExists(nameHash), "PMM:NEM");
        return (
            __s().erc20PaymentMethods[nameHash].erc20,
            __s().erc20PaymentMethods[nameHash].wethPair,
            __s().erc20PaymentMethods[nameHash].enabled
        );
    }

    function _addOrUpdateERC20PaymentMethod(
        string memory paymentMethodName,
        address erc20,
        address wethPair,
        bool enabled,
        string memory data
    ) internal {
        bytes32 nameHash = keccak256(abi.encode(paymentMethodName));
        __s().erc20PaymentMethods[nameHash].erc20 = erc20;
        __s().erc20PaymentMethods[nameHash].wethPair = wethPair;
        __s().erc20PaymentMethods[nameHash].enabled = enabled;
        address token0 = IUniswapV2Pair(wethPair).token0();
        address token1 = IUniswapV2Pair(wethPair).token1();
        require(token0 == __s().wethAddress || token1 == __s().wethAddress, "PMM:IPC");
        bool reverseIndices = (token1 == __s().wethAddress);
        __s().erc20PaymentMethods[nameHash].reverseIndices = reverseIndices;
        if (__s().erc20PaymentMethodNamesIndex[paymentMethodName] == 0) {
            __s().erc20PaymentMethodNames.push(paymentMethodName);
            __s().erc20PaymentMethodNamesIndex[paymentMethodName] =
                __s().erc20PaymentMethodNames.length;
        }
        emit ERC20PaymentMethodUpdate(
            paymentMethodName, erc20, wethPair, enabled, data);
    }

    function _enableERC20TokenPayment(
        string memory paymentMethodName,
        bool enabled
    ) internal {
        bytes32 nameHash = keccak256(abi.encode(paymentMethodName));
        require(_paymentMethodExists(nameHash), "PMM:NEM");
        __s().erc20PaymentMethods[nameHash].enabled = enabled;
        emit ERC20PaymentMethodUpdate(
            paymentMethodName,
            __s().erc20PaymentMethods[nameHash].erc20,
            __s().erc20PaymentMethods[nameHash].wethPair,
            enabled,
            ""
        );
    }

    function _handleWeiPayment(
        address payer,
        address dest,
        uint256 paidPriceWei, // could be the msg.value
        uint256 priceWeiToPay,
        string memory data
    ) internal {
        require(paidPriceWei >= priceWeiToPay, "PMM:IF");
        uint256 remainder = paidPriceWei - priceWeiToPay;
        if (dest != address(0)) {
            /* solhint-disable avoid-low-level-calls */
            (bool success, ) = dest.call{value: priceWeiToPay}(new bytes(0));
            /* solhint-enable avoid-low-level-calls */
            require(success, "PMM:TF");
            emit WeiPayment(payer, dest, paidPriceWei, priceWeiToPay, data);
        } else {
            emit WeiPayment(
                payer, address(this), paidPriceWei, priceWeiToPay, data);
        }
        if (remainder > 0) {
            /* solhint-disable avoid-low-level-calls */
            (bool success, ) = payer.call{value: remainder}(new bytes(0));
            /* solhint-enable avoid-low-level-calls */
            require(success, "PMM:RTF");
        }
    }

    function _handleERC20Payment(
        string memory paymentMethodName,
        address payer,
        address dest,
        uint256 priceWeiToPay,
        string memory data
    ) internal {
        bytes32 nameHash = keccak256(abi.encode(paymentMethodName));
        require(_paymentMethodExists(nameHash), "PMM:NEM");
        require(_paymentMethodEnabled(nameHash), "PMM:NENM");
        PaymentMethodManagerStorage.ERC20PaymentMethod memory paymentMethod =
            __s().erc20PaymentMethods[nameHash];
        (uint112 amount0, uint112 amount1,) = IUniswapV2Pair(paymentMethod.wethPair).getReserves();
        uint256 reserveWei = amount0;
        uint256 reserveTokens = amount1;
        if (paymentMethod.reverseIndices) {
            reserveWei = amount1;
            reserveTokens = amount0;
        }
        require(reserveWei > 0, "PMM:NWR");
        // TODO(kam): check if this is OK
        uint256 amountTokens = (priceWeiToPay * reserveTokens) / reserveWei;
        if (dest == address(0)) {
            dest = address(this);
        }
        // this contract must have already been approved by the msg.sender
        IERC20(paymentMethod.erc20).transferFrom(payer, dest, amountTokens);
        emit ERC20Payment(
            paymentMethodName, payer, dest, priceWeiToPay, amountTokens, data);
    }

    function _paymentMethodExists(
        bytes32 paymentMethodNameHash
    ) internal view returns (bool) {
        return __s().erc20PaymentMethods[paymentMethodNameHash].erc20 != address(0) &&
               __s().erc20PaymentMethods[paymentMethodNameHash].wethPair != address(0);
    }

    function _paymentMethodEnabled(
        bytes32 paymentMethodNameHash
    ) internal view returns (bool) {
        return __s().erc20PaymentMethods[paymentMethodNameHash].enabled;
    }

    function _getERC20PaymentMethodAddress(
        bytes32 paymentMethodNameHash
    ) internal view returns (address) {
        require(_paymentMethodExists(paymentMethodNameHash), "PMM:NEM");
        return __s().erc20PaymentMethods[paymentMethodNameHash].erc20;
    }

    function __s() private pure returns (PaymentMethodManagerStorage.Layout storage) {
        return PaymentMethodManagerStorage.layout();
    }
}
