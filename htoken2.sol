pragma solidity ^0.6.0;

import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

contract HToken is SafeERC20 {
    uint256 public totalSupply;
    uint256 public totalReserve;
    uint256 public value;
    uint256 public burnFee;
    IERC20 public paxGold;
    uint256 public maxBurnFee;

    event HTokenMinted(address indexed account, uint256 value);
    event HTokenBurned(address indexed account, uint256 value);

    constructor(IERC20 _paxGold, uint256 _burnFee, uint256 _maxBurnFee) public {
        paxGold = _paxGold;
        burnFee = _burnFee;
        maxBurnFee = _maxBurnFee;
    }

    function mint(uint256 _value) public {
        require(paxGold.balanceOf(msg.sender) >= _value, "Insufficient PaxGold balance");

        totalSupply += _value;
        totalReserve += _value;
        value = totalReserve / totalSupply;

        paxGold.transferFrom(msg.sender, address(this), _value);
        emit HTokenMinted(msg.sender, _value);
    }

    function burn(uint256 _value) public {
        require(balanceOf(msg.sender) >= _value, "Insufficient HToken balance");

        totalSupply -= _value;
        value = totalReserve / totalSupply;

        paxGold.transfer(msg.sender, _value * value);
        _burn(msg.sender, _value);
        emit HTokenBurned(msg.sender, _value);
    }

    function transfer(address recipient, uint256 amount) public override {
        uint256 calculatedBurnFee = amount.mul(burnFee).div(10000);

        if (calculatedBurnFee > maxBurnFee) {
            calculatedBurnFee = maxBurnFee;
        }

        totalSupply -= calculatedBurnFee;
        super.transfer(recipient, amount.sub(calculatedBurnFee));
        balanceOf[msg.sender] -= calculatedBurnFee;
        emit Burn(msg.sender, calculatedBurnFee);
    }
}
