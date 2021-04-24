// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";
import "../MED.sol";

/**
 * @dev Banking smart contracts - Term Deposit (Depot A Terme)
 */
contract DAT is Context {

    MED public medToken;

    uint256 public minimumAmount;
    uint16 public dayDuration;
    uint16 public interestRate;

    struct Product {
        uint256 _subscriptionAmount;
        uint256 _subscriptionDate;
    }

    mapping (address => Product) private _subscriptions;
    uint256 public daysElapsed;

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
    constructor (uint256 minimumAmountArg, uint16 dayDurationArg, uint16 interestRateArg, 
            address medTokenArg) {
        _issuingBank = _msgSender();
        minimumAmount = minimumAmountArg;
        dayDuration = dayDurationArg;
        interestRate = interestRateArg;
        medToken = MED(medTokenArg);
    }

    function incrementDay() public virtual onlyIssuingBank {
        daysElapsed = daysElapsed +1;
    }

    /**
     * Subscribe a new term deposit
     */
    function subscribeDat(uint256 depositAmount) public virtual {
        require(depositAmount >= minimumAmount, "Deposit amount is less than minimum required");
        require(_subscriptions[_msgSender()]._subscriptionAmount == 0, "Already subscribed");
        medToken.transferFrom(_msgSender(), address(this), depositAmount);
        _subscriptions[_msgSender()] = Product(depositAmount, daysElapsed);
    }

    /**
     * Cancelling a DAT is getting reimbursed your initial deposit at anytime without any interest
     */
    function cancelDat() public virtual {
        require(_subscriptions[_msgSender()]._subscriptionAmount > 0, "No active subscription");
        uint256 amount = _subscriptions[_msgSender()]._subscriptionAmount;
        delete _subscriptions[_msgSender()];
        medToken.transfer(_msgSender(), amount);
    }

    /**
     * Get your principal and your interest once the term ended
     */
    function payDat() public virtual {
        require(_subscriptions[_msgSender()]._subscriptionAmount > 0, "No active subscription");
        require(daysElapsed - _subscriptions[_msgSender()]._subscriptionDate > dayDuration, 
            "Too early to be payed");
        uint256 amount = _subscriptions[_msgSender()]._subscriptionAmount * (100+interestRate) / 100;
        delete _subscriptions[_msgSender()];
        medToken.transfer(_msgSender(), amount);
    }

}
