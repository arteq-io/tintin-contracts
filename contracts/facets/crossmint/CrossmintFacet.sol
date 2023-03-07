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
import "./CrossmintInternal.sol";

contract CrossmintFacet is IDiamondFacet {

    function getFacetName()
      external pure override returns (string memory) {
        return "crossmint";
    }

    // CAUTION: Don't forget to update the version when adding new functionality
    function getFacetVersion()
      external pure override returns (string memory) {
        return "3.0.0";
    }

    function getFacetPI()
      external pure override returns (string[] memory) {
        string[] memory pi = new string[](3);
        pi[0] = "getCrossmintSettings()";
        pi[1] = "setCrossmintSettings(bool,address)";
        pi[2] = "crossmintReserve(address,uint256)";
        return pi;
    }

    function getFacetProtectedPI()
      external pure override returns (string[] memory) {
        string[] memory pi = new string[](2);
        pi[0] = "setCrossmintSettings(bool,address)";
        pi[1] = "crossmintReserve(address,uint256)";
        return pi;
    }

    function supportsInterface(bytes4 interfaceId)
      external pure override returns (bool) {
        return interfaceId == type(IDiamondFacet).interfaceId;
    }

    function getCrossmintSettings() external view returns (bool, address) {
        return CrossmintInternal._getCrossmintSettings();
    }

    function setCrossmintSettings(
        bool crossmintEnabled,
        address crossmintTrustedAddress
    ) external {
        CrossmintInternal._setCrossmintSettings(
            crossmintEnabled,
            crossmintTrustedAddress
        );
    }

    function crossmintReserve(address to, uint256 nrOfTokens) external payable {
        CrossmintInternal._crossmintReserve(to, nrOfTokens);
    }
}
