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
import "../payment-method-manager/PaymentMethodManagerLib.sol";
import "./PaymentHandlerStorage.sol";

/// @author Kam Amini <kam@arteq.io>
///
/// @notice Use at your own risk
library PaymentHandlerInternal {

    bytes32 constant public WEI_PAYMENT_METHOD_HASH = keccak256(abi.encode("WEI"));

    event TransferTo(
        address to,
        uint256 amount,
        string data
    );
    event TransferETH20To(
        string paymentMethodName,
        address to,
        uint256 amount,
        string data
    );

    function _getPaymentHandlerSettings() internal view returns (address) {
        return __s().payoutAddress;
    }

    function _setPaymentHandlerSettings(
        address payoutAddress
    ) internal {
        __s().payoutAddress = payoutAddress;
    }

    function _transferTo(
        string memory paymentMethodName,
        address to,
        uint256 amount,
        string memory data
    ) internal {
        require(to != address(0), "PH:TTZ");
        require(amount > 0, "PH:ZAM");
        bytes32 nameHash = keccak256(abi.encode(paymentMethodName));
        require(nameHash == WEI_PAYMENT_METHOD_HASH ||
                PaymentMethodManagerLib._paymentMethodExists(nameHash), "PH:MNS");
        if (nameHash == WEI_PAYMENT_METHOD_HASH) {
            require(amount <= address(this).balance, "PH:MTB");
            /* solhint-disable avoid-low-level-calls */
            (bool success, ) = to.call{value: amount}(new bytes(0));
            /* solhint-enable avoid-low-level-calls */
            require(success, "PH:TF");
            emit TransferTo(to, amount, data);
        } else {
            address erc20 =
                PaymentMethodManagerLib._getERC20PaymentMethodAddress(nameHash);
            require(amount <= IERC20(erc20).balanceOf(address(this)), "PH:MTB");
            IERC20(erc20).transfer(to, amount);
            emit TransferETH20To(paymentMethodName, to, amount, data);
        }
    }

    function _handlePayment(
        uint256 nrOfItems1, uint256 priceWeiPerItem1,
        uint256 nrOfItems2, uint256 priceWeiPerItem2,
        string memory paymentMethodName
    ) internal {
        uint256 totalWei =
            nrOfItems1 * priceWeiPerItem1 +
            nrOfItems2 * priceWeiPerItem2;
        if (totalWei == 0) {
            return;
        }
        bytes32 nameHash = keccak256(abi.encode(paymentMethodName));
        require(nameHash == WEI_PAYMENT_METHOD_HASH ||
                PaymentMethodManagerLib._paymentMethodExists(nameHash), "PH:MNS");
        if (nameHash == WEI_PAYMENT_METHOD_HASH) {
            PaymentMethodManagerLib._handleWeiPayment(
                msg.sender, __s().payoutAddress, msg.value, totalWei, "");
        } else {
            PaymentMethodManagerLib.
                _handleERC20Payment(
                    paymentMethodName, msg.sender, __s().payoutAddress, totalWei, "");
        }
    }

    function __s() private pure returns (PaymentHandlerStorage.Layout storage) {
        return PaymentHandlerStorage.layout();
    }
}
