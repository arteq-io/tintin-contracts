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
import "./ReserveManagerInternal.sol";

/// @author Kam Amini <kam@arteq.io>
///
/// @notice Use at your own risk
contract ReserveManagerFacet is IDiamondFacet {

    function getFacetName()
      external pure override returns (string memory) {
        return "reserve-manager";
    }

    // CAUTION: Don't forget to update the version when adding new functionality
    function getFacetVersion()
      external pure override returns (string memory) {
        return "3.0.0";
    }

    function getFacetPI()
      external pure override returns (string[] memory) {
        string[] memory pi = new string[](4);
        pi[0] = "getReservationSettings()";
        pi[1] = "setReservationSettings(bool,bool,uint256,uint256)";
        pi[2] = "reserveForMe(uint256,string)";
        pi[3] = "reserveForAccounts(address[],uint256[])";
        return pi;
    }

    function getFacetProtectedPI()
      external pure override returns (string[] memory) {
        string[] memory pi = new string[](4);
        pi[1] = "setReservationSettings(bool,bool,uint256,uint256)";
        pi[2] = "reserveForMe(uint256,string)";
        pi[3] = "reserveForAccounts(address[],uint256[])";
        return pi;
    }

    function supportsInterface(bytes4 interfaceId)
      external pure override returns (bool) {
        return interfaceId == type(IDiamondFacet).interfaceId;
    }

    function getReservationSettings()
      external view returns (bool, bool, uint256, uint256, uint256) {
        return ReserveManagerInternal._getReservationSettings();
    }

    function setReservationSettings(
        bool reservationAllowed,
        bool reservationAllowedWithoutWhitelisting,
        uint256 reservationFeeWei,
        uint256 reservePriceWeiPerToken
    ) external {
        ReserveManagerInternal._setReservationSettings(
            reservationAllowed,
            reservationAllowedWithoutWhitelisting,
            reservationFeeWei,
            reservePriceWeiPerToken
        );
    }

    function reserveForMe(
        uint256 nrOfTokens,
        string memory paymentMethodName
    ) external payable {
        ReserveManagerInternal._reserveForAccount(
            msg.sender,
            nrOfTokens,
            paymentMethodName
        );
    }

    // This is always allowed
    function reserveForAccounts(
        address[] memory accounts,
        uint256[] memory nrOfTokensArray
    ) external {
        ReserveManagerInternal._reserveForAccounts(
            accounts,
            nrOfTokensArray
        );
    }
}
