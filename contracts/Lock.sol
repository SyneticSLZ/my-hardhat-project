// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AINFTS is ERC721URIStorage, Ownable, ERC721Royalty, ERC721Enumerable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // New mapping for token expirations
    mapping(uint256 => uint256) private _tokenExpirations;

    event Mint(uint256 tokenId, address recipient, string tokenURI, uint256 expiration);

    constructor() ERC721("AI NFTS", "AIN") {}

    // New function to manually expire a token
    function expireToken(uint256 tokenId) public onlyOwner {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        // Check if the token is not already expired to avoid unnecessary operations
        require(block.timestamp <= _tokenExpirations[tokenId], "Token is already expired");
        // Set the token's expiration to the current block timestamp, effectively expiring it
        _tokenExpirations[tokenId] = block.timestamp;
    }

    
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(
        uint256 tokenId
    ) internal override(ERC721, ERC721URIStorage, ERC721Royalty) {
        super._burn(tokenId);
        // Also clear the expiration on burn
        if (_tokenExpirations[tokenId] != 0) {
            delete _tokenExpirations[tokenId];
        }
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721Enumerable, ERC721Royalty) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");
        return super.tokenURI(tokenId);
    }

    function mintAiNft(
        string memory _tokenURI,
        uint256 duration,
        address recipient
    ) public returns (uint256) {
        uint256 newItemId = _tokenIds.current();
        _mint(recipient, newItemId);
        _setTokenURI(newItemId, _tokenURI);
        _tokenExpirations[newItemId] = block.timestamp + duration;

        emit Mint(newItemId, recipient, _tokenURI, _tokenExpirations[newItemId]);

        _tokenIds.increment();
        return newItemId;
    }

    function isTokenExpired(uint256 tokenId) public view returns (bool) {
        require(_exists(tokenId), "Query for nonexistent token");
        return block.timestamp > _tokenExpirations[tokenId];
    }
}
