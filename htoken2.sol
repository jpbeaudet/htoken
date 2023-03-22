// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract HToken is ERC20 {
    using SafeERC20 for IERC20;

    uint256 public totalReserve;
    uint256 public value;
    uint256 public burnFee;
    IERC20 public paxGold;
    uint256 public maxBurnFee;

    event HTokenMinted(address indexed account, uint256 value);
    event HTokenBurned(address indexed account, uint256 value);

    constructor(
        IERC20 _paxGold,
        uint256 _burnFee,
        uint256 _maxBurnFee,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) {
        paxGold = _paxGold;
        burnFee = _burnFee;
        maxBurnFee = _maxBurnFee;
    }

    function mint(uint256 _value) public {
        require(paxGold.balanceOf(msg.sender) >= _value, "Insufficient PaxGold balance");

        totalReserve += _value;
        value = totalReserve / totalSupply();

        paxGold.safeTransferFrom(msg.sender, address(this), _value);
        _mint(msg.sender, _value);
        emit HTokenMinted(msg.sender, _value);
    }

    function burn(uint256 _value) public {
        require(balanceOf(msg.sender) >= _value, "Insufficient HToken balance");

        totalReserve -= _value * value;
        value = totalReserve / totalSupply();

        paxGold.safeTransfer(msg.sender, _value * value);
        _burn(msg.sender, _value);
        emit HTokenBurned(msg.sender, _value);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        uint256 calculatedBurnFee = (amount * burnFee) / 10000;

        if (calculatedBurnFee > maxBurnFee) {
            calculatedBurnFee = maxBurnFee;
        }

        _burn(msg.sender, calculatedBurnFee);
        return super.transfer(recipient, amount - calculatedBurnFee);
    }
}
