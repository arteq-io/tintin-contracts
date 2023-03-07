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

import "../erc721/ERC721Lib.sol";
import "../minter/MinterLib.sol";
import "../whitelist-manager/WhitelistManagerLib.sol";
import "../payment-handler/PaymentHandlerLib.sol";
import "./ReserveManagerStorage.sol";

/// @author Kam Amini <kam@arteq.io>
///
/// @notice Use at your own risk
library ReserveManagerInternal {

    event ReserveToken(address account, uint256 tokenId);

    function _initReserveManager() internal {
        // We always keep the token #0 reserved for the contract
        __s().reservedTokenIdCounter = 1;
        __s().totalNrOfReservedTokens = 0;
    }

    function _getReservationSettings()
      internal view returns (bool, bool, uint256, uint256, uint256) {
        return (
            __s().reservationAllowed,
            __s().reservationAllowedWithoutWhitelisting,
            __s().reservationFeeWei,
            __s().reservePriceWeiPerToken,
            __s().totalNrOfReservedTokens
        );
    }

    function _setReservationSettings(
        bool reservationAllowed,
        bool reservationAllowedWithoutWhitelisting,
        uint256 reservationFeeWei,
        uint256 reservePriceWeiPerToken
    ) internal {
        __s().reservationAllowed = reservationAllowed;
        __s().reservationAllowedWithoutWhitelisting = reservationAllowedWithoutWhitelisting;
        __s().reservationFeeWei = reservationFeeWei;
        __s().reservePriceWeiPerToken = reservePriceWeiPerToken;
    }

    function _reserveForAccount(
        address account,
        uint256 nrOfTokens,
        string memory paymentMethodName
    ) internal {
        require(__s().reservationAllowed, "RM:NA");
        if (!__s().reservationAllowedWithoutWhitelisting) {
            uint256 nrOfWhitelistedTokens = WhitelistManagerLib._getWhitelistEntry(account);
            uint256 nrOfReservedTokens = __s().nrOfReservedTokens[account];
            require(nrOfReservedTokens < nrOfWhitelistedTokens, "RM:EMAX");
            require(nrOfTokens <= (nrOfWhitelistedTokens - nrOfReservedTokens), "RM:EMAX2");
        }
        PaymentHandlerLib._handlePayment(
            1, __s().reservationFeeWei,
            nrOfTokens, __s().reservePriceWeiPerToken,
            paymentMethodName
        );
        _reserve(account, nrOfTokens);
    }

    // NOTE: This is always allowed
    function _reserveForAccounts(
        address[] memory accounts,
        uint256[] memory nrOfTokensArray
    ) internal {
        require(accounts.length == nrOfTokensArray.length, "RM:II");
        for (uint256 i = 0; i < accounts.length; i++) {
            _reserve(accounts[i], nrOfTokensArray[i]);
        }
    }

    function _reserve(
        address account,
        uint256 nrOfTokens
    ) private {
        require(account != address(this), "RM:IA");
        for (uint256 i = 0; i < nrOfTokens; i++) {
            bool found = false;
            while (__s().reservedTokenIdCounter < MinterLib._getTokenIdCounter()) {
                if (ERC721Lib._ownerOf(__s().reservedTokenIdCounter) == address(this)) {
                    found = true;
                    break;
                }
                __s().reservedTokenIdCounter += 1;
            }
            if (found) {
                ERC721Lib._transfer(address(this), account, __s().reservedTokenIdCounter);
                emit ReserveToken(account, __s().reservedTokenIdCounter);
            } else {
                MinterLib._justMintTo(account);
                emit ReserveToken(account, MinterLib._getTokenIdCounter() - 1);
            }
            __s().reservedTokenIdCounter += 1;
        }
        __s().nrOfReservedTokens[account] += nrOfTokens;
        __s().totalNrOfReservedTokens += nrOfTokens;
    }

    function __s() private pure returns (ReserveManagerStorage.Layout storage) {
        return ReserveManagerStorage.layout();
    }
}
