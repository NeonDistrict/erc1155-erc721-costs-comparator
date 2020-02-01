pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721Full.sol";
import "openzeppelin-solidity/contracts/token/ERC721/ERC721Pausable.sol";
import "openzeppelin-solidity/contracts/access/roles/MinterRole.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./Libraries/Strings.sol";

contract OwnableDelegateProxy { }

contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}

contract ERC721Test is ERC721Full, ERC721Pausable, MinterRole, Ownable {
    using SafeMath for uint256;
    using Strings for string;

    address public proxyRegistryAddress;

    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        address proxyRegistry
    )
    ERC721Full(tokenName, tokenSymbol)
    public
    {
        proxyRegistryAddress = proxyRegistry;
    }

    /**
     * Set proxy after contract creation
     */

    function setProxyRegistryAddress(address proxyRegistry) external onlyOwner {
        proxyRegistryAddress = proxyRegistry;
    }

    /**
     * Generic minting by the type ID
     **/
    function mint(address[] calldata to) external onlyMinter returns (bool) {
        for (uint256 i = 0; i < to.length; ++i) {
            _mintHelper(to[i]);
        }
        return true;
    }

    function _mintHelper(address to) internal returns (bool) {
        uint256 tokenId = _getNextTokenId();
        _mint(to, tokenId);
        return true;
    }

    function _getNextTokenId() internal view returns (uint256) {
        // FUNCTIONS RELY ON THIS LOGIC, DO NOT CHANGE FOR A COUNTER!!!
        return totalSupply().add(1);
    }

    /**
     * Token URIs in our contracts should not be set 1-1 for each NFT, that's insane
     * Instead, use a generic format
     **/
    string public baseTokenURI = "";

    function setBaseTokenURI(string calldata _baseTokenURI) external onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    function tokenURI(uint256 _tokenId) external view returns (string memory) {
        return Strings.strConcat(
            baseTokenURI,
            Strings.uint2str(_tokenId)
        );
    }

    /**
     * Override isApprovedForAll to whitelist user's OpenSea proxy accounts to enable gas-less listings.
     */
    function isApprovedForAll(
        address tokenOwner,
        address tokenOperator
    )
        public
        view
        returns (bool)
    {
        // Whitelist OpenSea proxy contract for easy trading.
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        if (address(proxyRegistry.proxies(tokenOwner)) == tokenOperator) {
            return true;
        }

        return super.isApprovedForAll(tokenOwner, tokenOperator);
    }
}
