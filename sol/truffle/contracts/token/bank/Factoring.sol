// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./GenericProduct.sol";

/**
 * @dev Banking smart contracts - Factoring
 * @author AshtonIzmev
 */
contract Factoring is GenericProduct {

    using EnumerableSet for EnumerableSet.UintSet;

    struct Product {
        address _borrower;
        uint256 _factoringDate;
        uint256 _factoringAmount;
        bool _validated;
    }

    mapping (uint256 => Product) private _subscriptions;

    /**
     * param minimumAmount      minimum amount deposited
     * param dayDuration        duration of the DAT (in days)
     * param interestRate       interest rate of the DAT
     */
    constructor (address medToken_, address fpToken_) {
        _issuingBank = _msgSender();
        medToken = MED(medToken_);
        fpToken = FP(fpToken_);
    }

    /**
     * Get a token in exchange of an invoice
     */
    function sellInvoice(uint256 invoiceAmount_, address borrower_) public virtual {
        fpToken.create(_msgSender(), 1);
        uint256 tokenId = fpToken.getCurrentTokenId();
        _subscriptions[tokenId] = Product(borrower_, medToken.daysElapsed(), invoiceAmount_, false);
        _subscriptionIds.add(tokenId);
    }

    /**
     * Get a token in exchange of an invoice
     */
    function validateInvoice(uint256 tokenId) public virtual {
        require(isSuscribed(tokenId), "Existing Factoring subscription");
        Product memory prod = _subscriptions[tokenId];
        require(prod._borrower == _msgSender(), "Only borrower can validate");
        _subscriptions[tokenId] = 
            Product(prod._borrower, prod._factoringDate, prod._factoringAmount, true);
    }

    /**
     * Pay the owner of the FP NFT invoice representation
     */
    function payInvoice(uint256 tokenId) public virtual {
        require(isSuscribed(tokenId), "Existing Factoring subscription");
        Product memory prod = _subscriptions[tokenId];
        require(prod._borrower == _msgSender(), "Only borrower can pay");
        medToken.transferFrom(_msgSender(), fpToken.ownerOf(tokenId), prod._factoringAmount);
        fpToken.destroy(tokenId);
        _subscriptionIds.remove(tokenId);
    }
}