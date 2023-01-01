pragma solidity ^0.6.0;

import "./HToken.sol";

contract HTokenFactory {
  // The PaxGold contract.
  PaxGold public paxGold;

  // The burn fee, expressed as a percentage of the transferred amount.
  uint256 public burnFee;

  // The maximum burn fee, in HToken.
  uint256 public maxBurnFee;

  // The minimum amount of PaxGold that must be deposited to create a new HToken.
  uint256 public minDeposit;

  constructor(PaxGold _paxGold, uint256 _burnFee, uint256 _maxBurnFee, uint256 _minDeposit) public {
    paxGold = _paxGold;
    burnFee = _burnFee;
    maxBurnFee = _maxBurnFee;
    minDeposit = _minDeposit;
  }

  // Creates a new instance of the HToken contract.
  function createHToken(string memory name, string memory symbol) public {
    // Ensure the caller has deposited the minimum amount of PaxGold.
    require(paxGold.balanceOf(msg.sender) >= minDeposit, "Insufficient PaxGold balance");

    // Deploy a new instance of the HToken contract.
    HToken hToken = new HToken(paxGold, burnFee, maxBurnFee);

    // Set the name and symbol of the HToken.
    hToken.setup(name, symbol);

    // Transfer the minimum amount of PaxGold from the caller to the HToken contract.
    paxGold.transferFrom(msg.sender, address(hToken), minDeposit);

    // Mint the initial supply of HToken.
    hToken.mint(minDeposit);
  }
}
