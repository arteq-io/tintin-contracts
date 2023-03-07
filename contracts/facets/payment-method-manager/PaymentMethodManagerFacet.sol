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

import "../../diamond/IDiamondFacet.sol";
import "./PaymentMethodManagerInternal.sol";

/// @author Kam Amini <kam@arteq.io>
///
/// @notice Use at your own risk
contract PaymentMethodManagerFacet is IDiamondFacet {

    function getFacetName()
      external pure override returns (string memory) {
        return "payment-method-manager";
    }

    // CAUTION: Don't forget to update the version when adding new functionality
    function getFacetVersion()
      external pure override returns (string memory) {
        return "1.0.0";
    }

    function getFacetPI()
      external pure override returns (string[] memory) {
        string[] memory pi = new string[](6);
        pi[0] = "getPaymentMethodManagerSettings()";
        pi[1] = "setPaymentMethodManagerSettings(address)";
        pi[2] = "getERC20PaymentMethods()";
        pi[3] = "getERC20PaymentMethod(string)";
        pi[4] = "addOrUpdateERC20PaymentMethod(string,address,address)";
        pi[5] = "enableERC20TokenPayment(string,bool)";
        return pi;
    }

    function getFacetProtectedPI()
      external pure override returns (string[] memory) {
        string[] memory pi = new string[](4);
        pi[0] = "setPaymentMethodManagerSettings(address)";
        pi[1] = "addOrUpdateERC20PaymentMethod(string,address,address)";
        pi[2] = "enableERC20TokenPayment(string,bool)";
        pi[3] = "transferTo(string,address,uint256,string)";
        return pi;
    }

    function supportsInterface(bytes4 interfaceId)
      external pure override returns (bool) {
        return interfaceId == type(IDiamondFacet).interfaceId;
    }

    function getPaymentMethodManagerSettings() external view returns (address) {
        return PaymentMethodManagerInternal._getPaymentMethodManagerSettings();
    }

    function setPaymentMethodManagerSettings(
        address wethAddress
    ) external {
        PaymentMethodManagerInternal._setPaymentMethodManagerSettings(
            wethAddress
        );
    }

    function getERC20PaymentMethods() external view returns (string[] memory) {
        return PaymentMethodManagerInternal._getERC20PaymentMethods();
    }

    function getERC20PaymentMethod(
        string memory paymentMethodName
    ) external view returns (address, address, bool) {
        return PaymentMethodManagerInternal._getERC20PaymentMethod(paymentMethodName);
    }

    function addOrUpdateERC20PaymentMethod(
        string memory paymentMethodName,
        address addr,
        address wethPair,
        bool enabled,
        string memory data
    ) external {
        PaymentMethodManagerInternal._addOrUpdateERC20PaymentMethod(
            paymentMethodName,
            addr,
            wethPair,
            enabled,
            data
        );
    }

    function enableERC20TokenPayment(
        string memory paymentMethodName,
        bool enabled
    ) external {
        PaymentMethodManagerInternal._enableERC20TokenPayment(
            paymentMethodName,
            enabled
        );
    }
}
