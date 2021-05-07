// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../utils/Context.sol";
import "../med/MED.sol";
import "../nft/FP.sol";

/**
 * @dev Banking smart contracts - Term Deposit (Depot A Terme)
 */
contract DAT is Context {

    MED public medToken;
    FP public fpToken;

    uint256 public minimumAmount;
    uint256 public dayDuration;
    uint16 public interestRate;

    address _issuingBank;

    modifier onlyIssuingBank() {
        require(
            _msgSender() == _issuingBank,
            "Only Issuing Bank is allowed to call this"
        );
        _;
    }

    /**
     * The treasure account is the "root" account on this currency
     * param minimumAmount      minimum amount deposited
     * param dayDuration        duration of the DAT (in days)
     * param interestRate       interest rate of the DAT
     */
    constructor (uint256 minimumAmount_, uint256 dayDuration_, uint16 interestRate_, 
            address medToken_) {
        _issuingBank = _msgSender();
        minimumAmount = minimumAmount_;
        dayDuration = dayDuration_;
        interestRate = interestRate_;

        medToken = MED(medToken_);
        fpToken = new FP("DAT Share", "DAT", interestRate_, dayDuration_);
    }

    /**
     * Subscribe a new term deposit
     */
    function subscribeDat(uint256 depositAmount) public virtual {
        require(depositAmount >= minimumAmount, "Deposit amount is less than minimum required");
        medToken.transferFrom(_msgSender(), address(this), depositAmount);
        fpToken.create(_msgSender(), depositAmount, medToken.daysElapsed());
    }

    /**
     * Cancelling a DAT is getting reimbursed your initial deposit at anytime without any interest
     */
    function cancelDat(uint256 tokenId) public virtual {
        require(fpToken.ownerOf(tokenId) == _msgSender());
        uint256 initialAmount = fpToken.getSubAmount(tokenId);
        medToken.transfer(_msgSender(), initialAmount);
        fpToken.destroy(tokenId);
    }

    /**
     * Get your principal and your interest once the term ended
     */
    function payDat(uint256 tokenId) public virtual {
        require(fpToken.ownerOf(tokenId) == _msgSender());
        require(medToken.daysElapsed() - fpToken.getSubDate(tokenId) > dayDuration, 
            "Too early to be payed");
        uint256 initialAmount = fpToken.getSubAmount(tokenId);
        medToken.transfer(_msgSender(), initialAmount * (100+interestRate) / 100);
        fpToken.destroy(tokenId);        
    }

}
