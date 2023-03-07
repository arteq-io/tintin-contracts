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

import "../payment-handler/PaymentHandlerLib.sol";
import "./WhitelistManagerStorage.sol";

/// @author Kam Amini <kam@arteq.io>
///
/// @notice Use at your own risk
library WhitelistManagerInternal {

    event Whitelist(address account, uint256 nrOfTokens);

    function _getWhitelistingSettings()
      internal view returns (bool, uint256, uint256, uint256, uint256) {
        return (
            __s().whitelistingAllowed,
            __s().whitelistingFeeWei,
            __s().whitelistingPriceWeiPerToken,
            __s().maxNrOfWhitelistedTokensPerAccount,
            __s().totalNrOfWhitelists
        );
    }

    function _setWhitelistingSettings(
        bool whitelistingAllowed,
        uint256 whitelistingFeeWei,
        uint256 whitelistingPriceWeiPerToken,
        uint256 maxNrOfWhitelistedTokensPerAccount
    ) internal {
        __s().whitelistingAllowed = whitelistingAllowed;
        __s().whitelistingFeeWei = whitelistingFeeWei;
        __s().whitelistingPriceWeiPerToken = whitelistingPriceWeiPerToken;
        __s().maxNrOfWhitelistedTokensPerAccount = maxNrOfWhitelistedTokensPerAccount;
    }

    // NOTE: Send 0 for nrOfTokens to de-list the address
    function _whitelistMe(
        uint256 nrOfTokens,
        string memory paymentMethodName
    ) internal {
        require(__s().whitelistingAllowed, "WM:NA");
        PaymentHandlerLib._handlePayment(
            1, __s().whitelistingFeeWei,
            nrOfTokens, __s().whitelistingPriceWeiPerToken,
            paymentMethodName
        );
        _whitelist(msg.sender, nrOfTokens);
    }

    // Send 0 for nrOfTokens to de-list an address
    function _whitelistAccounts(
        address[] memory accounts,
        uint256[] memory nrOfTokensArray
    ) internal {
        require(__s().whitelistingAllowed, "WM:NA");
        require(accounts.length == nrOfTokensArray.length, "WM:IL");
        for (uint256 i = 0; i < accounts.length; i++) {
            _whitelist(accounts[i], nrOfTokensArray[i]);
        }
    }

    function _getWhitelistEntry(address account) internal view returns (uint256) {
        return __s().whitelistEntries[account];
    }

    function _whitelist(
        address account,
        uint256 nrOfTokens
    ) private {
        require(__s().maxNrOfWhitelistedTokensPerAccount == 0 ||
                nrOfTokens <= __s().maxNrOfWhitelistedTokensPerAccount,
                "WM:EMAX");
        __s().whitelistEntries[account] = nrOfTokens;
        emit Whitelist(account, nrOfTokens);
        __s().totalNrOfWhitelists += nrOfTokens;
    }

    function __s() private pure returns (WhitelistManagerStorage.Layout storage) {
        return WhitelistManagerStorage.layout();
    }
}
