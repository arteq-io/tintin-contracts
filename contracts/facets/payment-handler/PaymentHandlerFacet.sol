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
import "./PaymentHandlerInternal.sol";

/// @author Kam Amini <kam@arteq.io>
///
/// @notice Use at your own risk
contract PaymentHandlerFacet is IDiamondFacet {

    function getFacetName()
      external pure override returns (string memory) {
        return "payment-handler";
    }

    // CAUTION: Don't forget to update the version when adding new functionality
    function getFacetVersion()
      external pure override returns (string memory) {
        return "4.0.0";
    }

    function getFacetPI()
      external pure override returns (string[] memory) {
        string[] memory pi = new string[](3);
        pi[0] = "getPaymentHandlerSettings()";
        pi[1] = "setPaymentHandlerSettings(address)";
        pi[2] = "transferTo(string,address,uint256,string)";
        return pi;
    }

    function getFacetProtectedPI()
      external pure override returns (string[] memory) {
        string[] memory pi = new string[](2);
        pi[0] = "setPaymentSettings(address)";
        pi[1] = "transferTo(string,address,uint256,string)";
        return pi;
    }

    function supportsInterface(bytes4 interfaceId)
      external pure override returns (bool) {
        return interfaceId == type(IDiamondFacet).interfaceId;
    }

    function getPaymentHandlerSettings() external view returns (address) {
        return PaymentHandlerInternal._getPaymentHandlerSettings();
    }

    function setPaymentHandlerSettings(
        address payoutAddress
    ) external {
        PaymentHandlerInternal._setPaymentHandlerSettings(
            payoutAddress
        );
    }

    function transferTo(
        string memory paymentMethodName,
        address to,
        uint256 amount,
        string memory data
    ) external {
        PaymentHandlerInternal._transferTo(
            paymentMethodName,
            to,
            amount,
            data
        );
    }
}
