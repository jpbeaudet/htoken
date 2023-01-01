pragma solidity ^0.6.0;

import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";

// The HToken contract extends the SafeERC20 interface, which
// adds additional safety checks to the ERC20 interface.
contract HToken is SafeERC20 {
    // The total supply of HToken.
    uint256 public totalSupply;

    // The total reserve of PaxGold.
    uint256 public totalReserve;

    // The current value of 1 HToken in PaxGold.
    uint256 public value;

    // The burn fee, expressed as a percentage of the transferred amount.
    uint256 public burnFee;

    // The PaxGold contract.
    PaxGold public paxGold;

    constructor(PaxGold _paxGold, uint256 _burnFee) public {
        paxGold = _paxGold;
        burnFee = _burnFee;
    }

    // Mints new HToken in exchange for PaxGold.
function mint(uint256 _value) public {
    // Ensure the caller has sufficient PaxGold.
    require(paxGold.balanceOf(msg.sender) >= _value, "Insufficient PaxGold balance");

    // Increase the total supply of HToken.
    totalSupply += _value;

    // Increase the total reserve of PaxGold.
    totalReserve += _value;

    // Update the value of 1 HToken in PaxGold.
    value = totalReserve / totalSupply;

    // Transfer the PaxGold from the caller to the contract.
    paxGold.transferFrom(msg.sender, address(this), _value);
}


    // Burns HToken in exchange for PaxGold.
function burn(uint256 _value) public {
    // Ensure the caller has sufficient HToken.
    require(balanceOf(msg.sender) >= _value, "Insufficient HToken balance");

    // Decrease the total supply of HToken.
    totalSupply -= _value;

    // Update the value of 1 HToken in PaxGold.
    value = totalReserve / totalSupply;

    // Transfer the PaxGold from the contract to the caller.
    paxGold.transfer(msg.sender, _value * value);

    // Burn the HToken.
    _burn(msg.sender, _value);
}

// The maximum burn fee, in HToken.
uint256 public maxBurnFee;

function transfer(address recipient, uint256 amount) public {
  // Calculate the burn fee.
  uint256 burnFee = amount.mul(burnFee).div(10000);

  // Check if the burn fee exceeds the maximum burn fee.
  if (burnFee > maxBurnFee) {
    // Set the burn fee to the maximum burn fee.
    burnFee = maxBurnFee;
  }

  // Decrease the total supply by the burn fee.
  totalSupply -= burnFee;

  // Transfer the remaining amount to the recipient.
  super.transfer(recipient, amount.sub(burnFee));

  // Burn the fee amount.
  balanceOf[msg.sender] -= burnFee;
  emit Burn(msg.sender, burnFee);
}


}
