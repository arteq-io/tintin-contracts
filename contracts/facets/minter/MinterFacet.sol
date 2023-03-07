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
import "./MinterInternal.sol";

contract MinterFacet is IDiamondFacet {

    function getFacetName()
      external pure override returns (string memory) {
        return "minter";
    }

    // CAUTION: Don't forget to update the version when adding new functionality
    function getFacetVersion()
      external pure override returns (string memory) {
        return "4.0.0";
    }

    function getFacetPI()
      external pure override returns (string[] memory) {
        string[] memory pi = new string[](6);
        pi[0] = "getMintSettings()";
        pi[1] = "setMintSettings(bool,bool,uint256,uint256,uint256)";
        pi[2] = "preMint(uint256)";
        pi[3] = "mint(string[],string[],address[],uint256[],string)";
        pi[4] = "mintTo(address[],string[],string[],address[],uint256[])";
        pi[5] = "burn(uint256)";
        return pi;
    }

    function getFacetProtectedPI()
      external pure override returns (string[] memory) {
        string[] memory pi = new string[](4);
        pi[0] = "setMintSettings(bool,bool,uint256,uint256,uint256)";
        pi[1] = "preMint(uint256)";
        pi[2] = "mintTo(address[],string[],string[],address[],uint256[])";
        pi[3] = "burn(uint256)";
        return pi;
    }

    function supportsInterface(bytes4 interfaceId)
      external pure override returns (bool) {
        return interfaceId == type(IDiamondFacet).interfaceId;
    }

    function getMintSettings()
      external view returns (bool, bool, uint256, uint256, uint256, uint256, uint256) {
        return MinterInternal._getMintSettings();
    }

    function setMintSettings(
        bool publicMinting,
        bool directMintingAllowed,
        uint256 mintFeeWei,
        uint256 mintPriceWeiPerToken,
        uint256 maxTokenId
    ) external {
        MinterInternal._setMintSettings(
            publicMinting,
            directMintingAllowed,
            mintFeeWei,
            mintPriceWeiPerToken,
            maxTokenId
        );
    }

    function preMint(uint256 nrOfTokens) external {
        MinterInternal._preMint(nrOfTokens);
    }

    function mint(
        string[] memory uris,
        string[] memory datas,
        address[] memory royaltyWallets,
        uint256[] memory royaltyPercentages,
        string memory paymentMethodName
    ) external payable {
        (bool publicMinting,,,,,,)  = MinterInternal._getMintSettings();
        require(publicMinting, "MF:NPM");
        require(uris.length > 0, "MF:ZL");
        address[] memory owners = new address[](uris.length);
        for (uint256 i = 0; i < uris.length; i++) {
            owners[i] = msg.sender;
        }
        MinterInternal._mint(
            owners,
            uris,
            datas,
            royaltyWallets,
            royaltyPercentages,
            true,
            paymentMethodName
        );
    }

    function mintTo(
        address[] memory owners,
        string[] memory uris,
        string[] memory datas,
        address[] memory royaltyWallets,
        uint256[] memory royaltyPercentages
    ) external {
        MinterInternal._mint(
            owners,
            uris,
            datas,
            royaltyWallets,
            royaltyPercentages,
            false,
            ""
        );
    }

    function burn(uint256 tokenId) external payable {
        MinterInternal._burn(tokenId);
    }
}
