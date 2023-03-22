// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract HToken is ERC20 {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    uint256 private _totalReserve;
    uint256 public value;
    uint256 private _burnFee;
    uint256 private _maxBurnFee;
    IERC20 public paxGold;

event HTokenMinted(address indexed tokenAddress, string name, string symbol, address indexed account, uint256 value);
event HTokenBurned(address indexed tokenAddress, string name, string symbol, address indexed account, uint256 value);

    constructor(
        IERC20 _paxGold,
        uint256 _burnFee,
        uint256 _maxBurnFee,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) {
        paxGold = _paxGold;
        _burnFee = _burnFee;
        _maxBurnFee = _maxBurnFee;
    }
    
    function _updateValue() private view returns (uint256) {
        return totalSupply() == 0 ? 0 : _totalReserve.div(totalSupply());
    }

function mint(uint256 _value) public {
    require(paxGold.balanceOf(msg.sender) >= _value, "Insufficient PaxGold balance");

    _totalReserve = _totalReserve.add(_value);
    value = _updateValue();

    uint256 hTokenToMint = _value.div(value);

    paxGold.safeTransferFrom(msg.sender, address(this), _value);
    _mint(msg.sender, hTokenToMint);
    emit HTokenMinted(address(this), name(), symbol(), msg.sender, hTokenToMint);
}

    function burn(uint256 _value) public {
        require(balanceOf(msg.sender) >= _value, "Insufficient HToken balance");

        uint256 paxGoldValue = _value.mul(value);
        _totalReserve = _totalReserve.sub(paxGoldValue);
        value = _updateValue();

        paxGold.safeTransfer(msg.sender, paxGoldValue);
        _burn(msg.sender, _value);
        emit HTokenBurned(address(this), name(), symbol(), msg.sender, _value);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        uint256 calculatedBurnFee = amount.mul(_burnFee).div(10000);

        if (calculatedBurnFee > _maxBurnFee) {
            calculatedBurnFee = _maxBurnFee;
        }

        _burn(msg.sender, calculatedBurnFee);
        return super.transfer(recipient, amount - calculatedBurnFee);
    }
}

