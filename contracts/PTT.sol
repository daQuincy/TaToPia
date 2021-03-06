// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract PTT is ERC20, ERC20Permit, Ownable {
    address private _swapAddress;
    address private _rewardAddress;
    address private _burnAddress;

    uint256 private _decimals = 1000;
    uint256 private _buyRewardTaxRate = 20; // 2%
    uint256 private _buyBurnTaxRate = 0;
    uint256 private _sellRewardTaxRate = 20; // 2%
    uint256 private _sellBurnTaxRate = 10; // 1%
    uint256 private _maxTxnAmount;

    mapping(address => bool) _exemptFeesFrom;
    mapping(address => bool) _exemptFeesTo;

    event TransferWithTax(address from, address to, uint256 amount, uint256 tax);

    /**
     * @dev Sets the values for {name}, {symbol}, {initialAccount}, and {initialBalance}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(
        string memory name,
        string memory symbol,
        address initialAccount,
        uint256 initialBalance,
        address rewardAddress_,
        address burnAddress_
    ) payable ERC20(name, symbol) ERC20Permit(name) {
        _rewardAddress = rewardAddress_;
        _burnAddress = burnAddress_;

        _exemptFeesFrom[initialAccount] = true;
        _exemptFeesFrom[_rewardAddress] = true;
        _exemptFeesFrom[_burnAddress] = true;
        _exemptFeesTo[initialAccount] = true;
        _exemptFeesTo[_rewardAddress] = true;
        _exemptFeesTo[_burnAddress] = true;

        _maxTxnAmount = initialBalance / 100;
        _mint(initialAccount, initialBalance);
    }

    /**
     * @dev Sets the swap address
     */
    function setSwapAddress(address swapAddress_) public onlyOwner {
        _swapAddress = swapAddress_;
    }

    /**
     * @dev Sets the reward address
     */
    function setRewardAddress(address rewardAddress_) public onlyOwner {
        _rewardAddress = rewardAddress_;
    }

    /**
     * @dev Sets the burn address
     */
    function setBurnAddress(address burnAddress_) public onlyOwner {
        _burnAddress = burnAddress_;
    }

    /**
     * @dev Sets the max transaction percentage.
     */
    function setMaxTxnAmount(uint256 maxTxnAmount_) public onlyOwner() {
        _maxTxnAmount = maxTxnAmount_;
    }

    /**
     * @dev Sets the values for {buyRewardTaxRate}
     */
    function setBuyRewardTaxRate(uint256 buyRewardTaxRate_) public onlyOwner {
        _buyRewardTaxRate = buyRewardTaxRate_;
    }

    /**
     * @dev Sets the values for {buyBurnTaxRate}
     */
    function setBuyBurnTaxRate(uint256 buyBurnTaxRate_) public onlyOwner {
        _buyBurnTaxRate = buyBurnTaxRate_;
    }

    /**
     * @dev Sets the values for {sellRewardTaxRate}
     */
    function setSellRewardTaxRate(uint256 sellRewardTaxRate_) public onlyOwner {
        _sellRewardTaxRate = sellRewardTaxRate_;
    }

    /**
     * @dev Sets the values for {sellBurnTaxRate}
     */
    function setSellBurnTaxRate(uint256 sellBurnTaxRate_) public onlyOwner {
        _sellBurnTaxRate = sellBurnTaxRate_;
    }

    /**
     * @dev Set fees exemption for transaction from {addr} to be {boolean}
     */
    function setExemptFeesFrom(address addr, bool boolean) public onlyOwner {
        _exemptFeesFrom[addr] = boolean;
    }

    /**
     * @dev Set fees exemption for transaction to {addr} to be {boolean}
     */
    function setExemptFeesTo(address addr, bool boolean) public onlyOwner {
        _exemptFeesTo[addr] = boolean;
    }

    /**
     * @dev Returns the swap address.
     */
    function swapAddress() public view returns (address) {
        return _swapAddress;
    }

    function maxTxnAmount() public view returns (uint256) {
        return _maxTxnAmount;
    }

    /**
     * @dev Returns the reward address.
     */
    function rewardAddress() public view returns (address) {
        return _rewardAddress;
    }

    /**
     * @dev Returns the burn address.
     */
    function burnAddress() public view returns (address) {
        return _burnAddress;
    }

    /**
     * @dev Returns the reward tax rate when buying the token.
     */
    function buyRewardTaxRate() public view returns (uint256) {
        return _buyRewardTaxRate;
    }

    /**
     * @dev Returns the burn tax rate when buying the token.
     */
    function buyBurnTaxRate() public view returns (uint256) {
        return _buyBurnTaxRate;
    }

    /**
     * @dev Returns the reward tax rate when sell the token.
     */
    function sellRewardTaxRate() public view returns (uint256) {
        return _sellRewardTaxRate;
    }

    /**
     * @dev Returns the burn tax rate when sell the token.
     */
    function sellBurnTaxRate() public view returns (uint256) {
        return _sellBurnTaxRate;
    }

    /**
     * @dev Returns true transactions from {addr} is exempted from fees
     */
    function isExemptFeesFrom(address addr) public view returns (bool) {
        return _exemptFeesFrom[addr];
    }

    /**
     * @dev Returns true if transactions to {addr} is exempted from fees
     */
    function isExemptFeesTo(address addr) public view returns (bool) {
        return _exemptFeesTo[addr];
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(this.balanceOf(sender) >= amount, "ERC20: transfer amount exceeds balance");
        if(sender != owner() && recipient != owner() && sender != address(this))
            require(amount <= _maxTxnAmount, "Transfer amount exceeds the maxTxnAmount.");

        uint256 tax = 0;

        if (sender == _swapAddress) {
            if (!isExemptFeesTo(recipient)) {
                if (_buyRewardTaxRate > 0) {
                    uint256 rewardTax = (amount * _buyRewardTaxRate) / _decimals;
                    tax += rewardTax;
                    super._transfer(sender, _rewardAddress, rewardTax);
                }

                if (_buyBurnTaxRate > 0) {
                    uint256 burnTax = (amount * _buyBurnTaxRate) / _decimals;
                    tax += burnTax;
                    super._transfer(sender, _burnAddress, burnTax);
                }
            }
        } else {
            if (!isExemptFeesFrom(sender) && !isExemptFeesTo(recipient)) {
                if (_sellRewardTaxRate > 0) {
                    uint256 rewardTax = (amount * _sellRewardTaxRate) / _decimals;
                    tax += rewardTax;
                    super._transfer(sender, _rewardAddress, rewardTax);
                }

                if (_sellBurnTaxRate > 0) {
                    uint256 burnTax = (amount * _sellBurnTaxRate) / _decimals;
                    tax += burnTax;
                    super._transfer(sender, _burnAddress, burnTax);
                }
            }
        }

        // Send remaining amount
        super._transfer(sender, recipient, amount - tax);
        emit TransferWithTax(sender, recipient, amount, tax);
    }
}
