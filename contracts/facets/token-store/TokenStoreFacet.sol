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

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "../../diamond/IDiamondFacet.sol";
import "./TokenStoreInternal.sol";

/// @author Kam Amini <kam@arteq.io>
///
/// @notice Use at your own risk
contract TokenStoreFacet is IDiamondFacet {

    function getFacetName()
      external pure override returns (string memory) {
        return "token-store";
    }

    // CAUTION: Don't forget to update the version when adding new functionality
    function getFacetVersion()
      external pure override returns (string memory) {
        return "3.0.0";
    }

    function getFacetPI()
      external pure override returns (string[] memory) {
        string[] memory pi = new string[](9);
        pi[0] = "getTokenStoreSettings()";
        pi[1] = "setTokenStoreSettings(string,string)";
        pi[2] = "getTokenData(uint256)";
        pi[3] = "setTokenData(uint256,string)";
        pi[4] = "getTokenURI(uint256)";
        pi[5] = "setTokenURI(uint256,string)";
        pi[6] = "updateTokens(uint256[],string[],string[])";
        pi[7] = "ownedTokens(address)";
        pi[8] = "findToken(string)";
        return pi;
    }

    function getFacetProtectedPI()
      external pure override returns (string[] memory) {
        string[] memory pi = new string[](4);
        pi[0] = "setTokenStoreSettings(string,string)";
        pi[1] = "setTokenData(uint256,string)";
        pi[2] = "setTokenURI(uint256,string)";
        pi[3] = "updateTokens(uint256[],string[],string[])";
        return pi;
    }

    function supportsInterface(bytes4 interfaceId)
      external pure override returns (bool) {
        return interfaceId == type(IDiamondFacet).interfaceId ||
               interfaceId == type(IERC721Metadata).interfaceId;
    }

    function getTokenStoreSettings()
      external view returns (string memory, string memory) {
        return TokenStoreInternal._getTokenStoreSettings();
    }

    function setTokenStoreSettings(
        string memory baseTokenURI,
        string memory defaultTokenURI
    ) external {
        TokenStoreInternal._setTokenStoreSettings(
            baseTokenURI,
            defaultTokenURI
        );
    }

    function getTokenData(uint256 tokenId)
      external view returns (string memory) {
        return TokenStoreInternal._getTokenData(tokenId);
    }

    function setTokenData(
        uint256 tokenId,
        string memory data
    ) external {
        TokenStoreInternal._setTokenData(tokenId, data);
    }

    function getTokenURI(uint256 tokenId)
      public view returns (string memory) {
        return TokenStoreInternal._getTokenURI(tokenId);
    }

    function setTokenURI(
        uint256 tokenId,
        string memory tokenURI
    ) external {
        return TokenStoreInternal._setTokenURI(tokenId, tokenURI);
    }

    function updateTokens(
        uint256[] memory tokenIds,
        string[] memory uris,
        string[] memory datas
    ) external {
        TokenStoreInternal._updateTokens(
            tokenIds,
            uris,
            datas
        );
    }

    function ownedTokens(address account)
      external view returns (uint256[] memory tokens) {
        return TokenStoreInternal._ownedTokens(account);
    }

    function findToken(string memory evidence)
      external view returns (uint256) {
        return TokenStoreInternal._findToken(evidence);
    }
}
