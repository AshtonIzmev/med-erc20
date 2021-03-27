// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20/IERC20MED.sol";
import "./ERC20/extensions/IERC20MEDMetadata.sol";
import "./ERC20/utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface as a sovereign moroccan crypto-currency
 *
 */
contract MED is Context, IERC20MED, IERC20MEDMetadata {

    mapping (address => uint256) private _balances;

    uint256 private _totalSupply;

    address _centralBank;
    address _treasureAccount;

    string private _name = "Morrocan E-Dirham";
    string private _symbol = "MED";

    modifier onlyCentralBank() {
        require(
            msg.sender == _centralBank,
            "Only Central Bank is allowed to call this"
        );
        _;
    } 

    /**
     * The treasure account is the "root" account on this crypto-currency
     */
    constructor (address treasureAccount) {
        _treasureAccount = treasureAccount;
        _centralBank = msg.sender;
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

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function mint(uint256 amount) public virtual onlyCentralBank {
        _mint(_treasureAccount, amount);
    }

    function burn(uint256 amount) public virtual onlyCentralBank {
        _burn(_treasureAccount, amount);
    }

    /**
    *
    * * * * * * * * * * * * *
    * Internal functions    *
    * * * * * * * * * * * * *
    *
    */

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

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}
