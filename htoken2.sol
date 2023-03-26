// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8 .0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/**

@title HToken

@dev HToken is an ERC20 token that is backed by Pax Gold (PAXG).

The value of the token is derived from the amount of PAXG in the reserve.

HToken can be minted and burned by depositing and withdrawing PAXG from the reserve.

A small percentage of each transfer is burned, decreasing the total supply and increasing the value of each token.
*/
contract HToken is ERC20 {
    using SafeERC20
    for IERC20;
    using SafeMath
    for uint256;

    uint256 private _totalReserve; // Total amount of PAXG in the reserve
    uint256 public value; // The value of each token, expressed in PAXG
    uint256 private _burnFee = 25; // 0.025% burn rate (in basis points)
    uint256 private _maxBurnFee = 10; // Max burn fee in HToken
    IERC20 public paxGold; // The PAXG contract

    event HTokenMinted(address indexed tokenAddress, string name, string symbol, address indexed account, uint256 value);
    event HTokenBurned(address indexed tokenAddress, string name, string symbol, address indexed account, uint256 value);

    /**

    @dev Constructor for HToken contract

    @param _paxGold The address of the PAXG contract

    @param initialDeposit The initial amount of PAXG to deposit into the reserve

    @param initialSupply The initial supply of HToken to mint

    @param _name The name of the HToken

    @param _symbol The symbol of the HToken

    @param userAddress The address of the user that will receive the initial supply of HToken
    */
    constructor(
        IERC20 _paxGold,
        uint256 initialDeposit,
        uint256 initialSupply,
        string memory _name,
        string memory _symbol,
        address userAddress
    ) ERC20(_name, _symbol) {
        paxGold = _paxGold;

        require(initialDeposit > 0, "Initial deposit must be greater than zero");
        require(initialSupply > 0, "Initial supply must be greater than zero");
        require(paxGold.balanceOf(msg.sender) >= initialDeposit, "Insufficient PaxGold balance");

        _totalReserve = initialDeposit;
        value = _totalReserve.div(initialSupply);
        require(paxGold.transferFrom(userAddress, address(this), initialDeposit), "Token transfer failed");
        _mint(userAddress, initialSupply);
    }

    /**

    @dev Calculates the current value of each HToken
    @return The value of each HToken, expressed in PAXG
    */
    function _updateValue() public view returns(uint256) {
        return totalSupply() == 0 ? 0 : _totalReserve.div(totalSupply());
    }
    /**

    @dev Mint new HToken by depositing PAXG into the reserve

    @param _value The amount of PAXG to deposit
    */
    function mint(uint256 _value) public {
        require(paxGold.balanceOf(msg.sender) >= _value, "Insufficient PaxGold balance");

        _totalReserve = _totalReserve.add(_value);
        value = _updateValue();

        uint256 hTokenToMint = _value.div(value);

        paxGold.safeTransferFrom(msg.sender, address(this), _value);
        _mint(msg.sender, hTokenToMint);
        emit HTokenMinted(address(this), name(), symbol(), msg.sender, hTokenToMint);
    }

    /**

    @dev Burn HToken and receive PAXG in return

    @param _value The amount of HToken to burn
    */
    function burn(uint256 _value) public {
        require(balanceOf(msg.sender) >= _value, "Insufficient HToken balance");

        uint256 paxGoldValue = _value.mul(value);
        _totalReserve = _totalReserve.sub(paxGoldValue);
        value = _updateValue();

        paxGold.safeTransfer(msg.sender, paxGoldValue);
        _burn(msg.sender, _value);
        emit HTokenBurned(address(this), name(), symbol(), msg.sender, _value);
    }

    /**

    @dev Transfer HToken while applying a burn fee

    @param recipient The address to transfer HToken to

    @param amount The amount of HToken to transfer

    @return A boolean indicating if the transfer was successful or not
    */
    function transfer(address recipient, uint256 amount) public override returns(bool) {
        uint256 calculatedBurnFee = amount.mul(_burnFee).div(10000);

        if (calculatedBurnFee > _maxBurnFee) {
            calculatedBurnFee = _maxBurnFee;
        }

        _burn(msg.sender, calculatedBurnFee);
        return super.transfer(recipient, amount.sub(calculatedBurnFee));
    }

    /**

    @dev Transfer HToken from a specified address to another while applying a burn fee

    @param sender The address to transfer HToken from

    @param recipient The address to transfer HToken to

    @param amount The amount of HToken to transfer

    @return A boolean indicating if the transfer was successful or not
    */
    function transferFrom(address sender, address recipient, uint256 amount) public override returns(bool) {
        uint256 calculatedBurnFee = amount.mul(_burnFee).div(10000);

        if (calculatedBurnFee > _maxBurnFee) {
            calculatedBurnFee = _maxBurnFee;
        }

        _burn(sender, calculatedBurnFee);
        return super.transferFrom(sender, recipient, amount.sub(calculatedBurnFee));
    }

    /**

    @dev Get HToken contract details
    @return A tuple containing the HToken name, symbol, total supply, and current value of the HToken
    */
    function getDetails() public view returns(string memory, string memory, uint256, uint256) {
        return (name(), symbol(), totalSupply(), value);
    }
