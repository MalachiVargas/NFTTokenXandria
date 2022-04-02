// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import {ERC721} from "solmate/tokens/ERC721.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";

error TokenDoesNotExist();
error MaxSupplyReached();
error WrongEtherAmount();
error MaxAmountPerTrxReached();
error NoEthBalance();

/// @title ERC721 NFT Drop
/// @title NFTToken
/// @author Malachi <mcvarga7@gmail.com>

contract NFTToken is ERC721, Ownable {
    using Strings for uint256;

    uint256 public totalSupply = 0;
    string public baseURI;
    uint256 public immutable maxSupply = 5;
    uint256 public immutable price =
     0.15 ether;
    uint256 public maxMintPerTrx = 5;

    address public withdrawalAddress = 0xc4B77F4200755988e818BcdE9635392f325ACC25;

    /*///////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseURI
    ) ERC721(_name, _symbol) {
        baseURI = _baseURI;
    }

    /*///////////////////////////////////////////////////////////////
                               MINT FUNCTION
    //////////////////////////////////////////////////////////////*/

    function mintNft(uint256 amount) external payable {
        if (amount > maxMintPerTrx) revert MaxAmountPerTrxReached();
        if (totalSupply + amount > maxSupply) revert MaxSupplyReached();
        if (msg.value < price * amount) revert WrongEtherAmount();
        
        unchecked {
            for (uint256 index = 0; index < amount; index++) {
                uint256 tokenId = totalSupply + 1;
                _mint(msg.sender, tokenId);
                totalSupply++;
            }
        }
    }
    
    /*///////////////////////////////////////////////////////////////
                            ETH WITHDRAWAL
    //////////////////////////////////////////////////////////////*/

    function withdraw() external onlyOwner {
        if (address(this).balance == 0) revert NoEthBalance();
        SafeTransferLib.safeTransferETH(withdrawalAddress, address(this).balance);
    }

    function tokenURI(uint256 tokenId) 
            public
            view
            override
            returns (string memory)
        {
            if (ownerOf[tokenId] == address(0)) {
                revert TokenDoesNotExist();
            }

            return
                bytes(baseURI).length > 0
                    ? string(abi.encodePacked(baseURI, tokenId.toString(), ".json"))
                    : "";
        }
}
