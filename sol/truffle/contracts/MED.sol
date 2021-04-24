// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20/IERC20.sol";
import "./ERC20/extensions/IERC20Metadata.sol";
import "./utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface as a sovereign moroccan crypto-currency
 *
 */
contract MED is Context, IERC20, IERC20Metadata {

    mapping (address => uint256) private _balances;

    uint256 private _totalSupply;

    address _centralBank;
    address _treasureAccount;

    mapping (address => uint256) private _lastDayTax;
    uint256 public daysElapsed;
    uint32 public dailyTaxRate;

    mapping (address => uint256) private _lastMonthIncome;
    uint256 public monthsElapsed;
    uint256 public universalMonthlyIncome;

    string private _name = "Moroccan E-Dirham";
    string private _symbol = "MED";

    bool public allowMint = false;

    mapping (address => mapping (address => uint256)) private _allowances;

    modifier onlyCentralBank() {
        require(
            _msgSender() == _centralBank,
            "Only Central Bank is allowed to call this"
        );
        _;
    } 

    /**
     * The treasure account is the "root" account on this currency
     * param annualTaxRatePercent : percentage of the account that would be taxed in a year
     *                              tax is applied daily
     * param umi : Universal Monthly Income
     * param allowMint : Should we allow central bank to mint new tokens ?
     */
    constructor (address treasureAccount, uint32 annualTaxRatePercent, uint256 umi, 
        bool allowMintArg, uint256 initialMint) {
        _centralBank = _msgSender();
        _treasureAccount = treasureAccount;
        dailyTaxRate = annualTaxRatePercent * 10000 / 365;
        universalMonthlyIncome = umi;
        allowMint = allowMintArg;
        _mint(_treasureAccount, initialMint);
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * MED cyrpto-currency only uses "cents" or "centimes" as a subdivision
     */
    function decimals() public view virtual override returns (uint8) {
        return 2;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function elapsedTaxDaysOf(address account) public view virtual returns (uint256) {
        return _lastDayTax[account];
    }

    function elapsedIncomeMonthOf(address account) public view virtual returns (uint256) {
        return _lastMonthIncome[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _updateAccount(_msgSender());
        _updateAccount(recipient);
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function updateAccount(address taxPayer) public virtual {
        _updateAccount(taxPayer);
    }

    function mint(uint256 amount) public virtual onlyCentralBank {
        require(allowMint);
        _mint(_treasureAccount, amount);
    }

    function burn(uint256 amount) public virtual onlyCentralBank {
        _burn(_treasureAccount, amount);
    }

    function incrementDay() public virtual onlyCentralBank {
        daysElapsed = daysElapsed +1;
    }

    function incrementMonth() public virtual onlyCentralBank {
        monthsElapsed = monthsElapsed +1;
    }

    function setNewDailyTaxRate(uint32 newRate) public virtual onlyCentralBank {
        dailyTaxRate = newRate;
    }

    function setNewBasicIncome(uint256 newIncome) public virtual onlyCentralBank {
        universalMonthlyIncome = newIncome;
    }
    
    /**
    *
    * * * * * * * * * * * * *
    * Internal functions    *
    * * * * * * * * * * * * *
    *
    */

    function _calculateIncome(address taxPayer) internal view virtual returns (uint256) {
        if (taxPayer == _treasureAccount) {
            return 0;
        }
        uint256 taxPayerMonthsElapsed = monthsElapsed - _lastMonthIncome[taxPayer];
        if (taxPayerMonthsElapsed == 0) {
            return 0;
        }
        return taxPayerMonthsElapsed * universalMonthlyIncome;
    }

    function _calculateTax(address taxPayer) internal view virtual returns (uint256) {
        if (taxPayer == _treasureAccount) {
            return 0;
        }
        uint256 taxPayerdaysElapsed = daysElapsed - _lastDayTax[taxPayer];
        if (taxPayerdaysElapsed == 0) {
            return 0;
        }
        uint256 taxToPay = _balances[taxPayer] * taxPayerdaysElapsed * dailyTaxRate / (1000 * 1000);
        return taxToPay;
    }

    function _updateAccount(address taxPayer) internal virtual{
        _transferIncome(taxPayer);
        _deductTax(taxPayer);
    }

    function _transferIncome(address taxPayer) internal virtual {
        uint256 umi = _calculateIncome(taxPayer);
        _lastMonthIncome[taxPayer] = monthsElapsed;
        _transfer(_treasureAccount, taxPayer, umi);
    }

    function _deductTax(address taxPayer) internal virtual {
        uint256 taxToPay = _calculateTax(taxPayer);
        _lastDayTax[taxPayer] = daysElapsed;
        _transfer(taxPayer, _treasureAccount, taxToPay);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        require(account == _treasureAccount, "Mint can only be done to treasury account");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }


    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        require(account == _treasureAccount, "Burn can only be done to treasury account");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount; 

        emit Transfer(account, address(0), amount);
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }
    
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }
    
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}
