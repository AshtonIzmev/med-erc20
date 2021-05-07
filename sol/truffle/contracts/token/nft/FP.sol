// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../token/ERC721/ERC721.sol";
import "../../utils/Counters.sol";

/**
    NFT representing a share of a finance product (term deposit, crowdunfing, investment etc.)
 */
contract FP is ERC721 {
    
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    uint16 public interestRate;
    uint256 public maturity;

    struct Product {
        uint256 _subscriptionAmount;
        uint256 _subscriptionDate;
    }

    mapping (uint256 => Product) private _subscriptions;

    address public creator;

    modifier onlyCreator() { 
        require(_msgSender() == creator, "Only the creator is allowed to call this");
        _;
    }

    constructor(string memory name_, string memory symbol_, uint16 interestRate_, uint256 maturity_) 
        ERC721(name_, symbol_) {
            creator = _msgSender();
            interestRate = interestRate_;
            maturity = maturity_;
    }

    function _baseURI() internal virtual view override returns (string memory) {
        return "https://curieux.ma/";
    }

    function getSubAmount(uint256 tokenId) public virtual view returns (uint256) {
        return _subscriptions[tokenId]._subscriptionAmount;
    }

    function getSubDate(uint256 tokenId) public virtual view returns (uint256) {
        return _subscriptions[tokenId]._subscriptionDate;
    }

    function create(address buyer, uint256 amount, uint256 subscriptionDate) 
        public virtual onlyCreator {
        _safeMint(buyer, _tokenIds.current());
        _subscriptions[_tokenIds.current()] = Product(amount, subscriptionDate);
        _tokenIds.increment();
    }

    function destroy(uint256 tokenId) public virtual onlyCreator {
        _burn(tokenId);
    }

}