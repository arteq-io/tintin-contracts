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

import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "../../diamond/IDiamondFacet.sol";
import "./RoyaltyManagerInternal.sol";

/// @author Kam Amini <kam@arteq.io>
///
/// @notice Use at your own risk
contract RoyaltyManagerFacet is IDiamondFacet {

    function getFacetName()
      external pure override returns (string memory) {
        return "royalty-manager";
    }

    // CAUTION: Don't forget to update the version when adding new functionality
    function getFacetVersion()
      external pure override returns (string memory) {
        return "3.0.0";
    }

    function getFacetPI()
      external pure override returns (string[] memory) {
        string[] memory pi = new string[](6);
        pi[0] = "getDefaultRoyaltySettings()";
        pi[1] = "setDefaultRoyaltySettings(address,uint256)";
        pi[2] = "getTokenRoyaltyInfo(uint256)";
        pi[3] = "setTokenRoyaltyInfo(uint256,address,uint256)";
        pi[4] = "exemptTokenRoyalty(uint256,bool)";
        pi[5] = "royaltyInfo(uint256,uint256)";
        return pi;
    }

    function getFacetProtectedPI()
      external pure override returns (string[] memory) {
        string[] memory pi = new string[](3);
        pi[0] = "setDefaultRoyaltySettings(address,uint256)";
        pi[1] = "setTokenRoyaltyInfo(uint256,address,uint256)";
        pi[2] = "exemptTokenRoyalty(uint256,bool)";
        return pi;
    }

    function supportsInterface(bytes4 interfaceId)
      external pure override returns (bool) {
        return interfaceId == type(IDiamondFacet).interfaceId ||
               interfaceId == type(IERC2981).interfaceId;
    }

    function getDefaultRoyaltySettings() external view returns (address, uint256) {
        return RoyaltyManagerInternal._getDefaultRoyaltySettings();
    }

    // Either set address to zero or set percentage to zero to disable
    // default royalties. Still, royalties set per token work.
    function setDefaultRoyaltySettings(
        address newDefaultRoyaltyWallet,
        uint256 newDefaultRoyaltyPercentage
    ) external {
        RoyaltyManagerInternal._setDefaultRoyaltySettings(
            newDefaultRoyaltyWallet,
            newDefaultRoyaltyPercentage
        );
    }

    function getTokenRoyaltyInfo(uint256 tokenId)
      external view returns (address, uint256, bool) {
        return RoyaltyManagerInternal._getTokenRoyaltyInfo(tokenId);
    }

    function setTokenRoyaltyInfo(
        uint256 tokenId,
        address royaltyWallet,
        uint256 royaltyPercentage
    ) external {
        RoyaltyManagerInternal._setTokenRoyaltyInfo(
            tokenId,
            royaltyWallet,
            royaltyPercentage
        );
    }

    function exemptTokenRoyalty(uint256 tokenId, bool exempt) external {
        RoyaltyManagerInternal._exemptTokenRoyalty(tokenId, exempt);
    }

    function royaltyInfo(
        uint256 tokenId,
        uint256 salePrice
    ) external view returns (address, uint256) {
        return RoyaltyManagerInternal._getRoyaltyInfo(tokenId, salePrice);
    }
}
