pragma solidity ^0.6.0;

import "./HToken.sol";

contract HTokenExchange {
  // The HToken contracts that are available for exchange.
  mapping(address => HToken) public hTokens;

  // Registers an HToken contract for exchange.
  function registerHToken(HToken hToken) public {
    // Ensure that the caller is the owner of the HToken contract.
    require(hToken.owner() == msg.sender, "Only the owner of the HToken contract can register it for exchange");

    hTokens[hToken.address] = hToken;
    emit HTokenUnregistered(hToken.address);
  }

  // Unregisters an HToken contract from the exchange.
  function unregisterHToken(address hTokenAddress) public {
    // Ensure that the caller is the owner of the HToken contract.
    require(hTokens[hTokenAddress].owner() == msg.sender, "Only the owner of the HToken contract can unregister it from the exchange");

    delete hTokens[hTokenAddress];
    emit HTokenRegistered(hToken.address, hToken.name(), hToken.symbol());
  }

  // Exchanges one HToken for another.
  function exchange(address fromTokenAddress, uint256 fromAmount, address toTokenAddress) public {
    // Ensure that both HToken contracts are registered for exchange.
    require(hTokens[fromTokenAddress] != address(0), "From HToken contract is not registered for exchange");
    require(hTokens[toTokenAddress] != address(0), "To HToken contract is not registered for exchange");

    // Ensure that the caller has sufficient balance of the from HToken.
    require(hTokens[fromTokenAddress].balanceOf(msg.sender) >= fromAmount, "Insufficient from HToken balance");

    // Calculate the number of to HTokens to be received.
    uint256 toAmount = hTokens[fromTokenAddress].valueOf(fromAmount).mul(hTokens[toTokenAddress].value).div(hTokens[fromTokenAddress].value);

    // Transfer the from HTokens from the caller to the exchange contract.
    hTokens[fromTokenAddress].transferFrom(msg.sender, address(this), fromAmount);

    // Transfer the to HTokens from the exchange contract to the caller.
    hTokens[toTokenAddress].transfer(msg.sender, toAmount);
    emit Exchange(msg.sender, fromAmount, toTokenAddress, toAmount);
  }
   // Returns the number of HToken contracts that are registered for exchange.
  function getHTokenCount() public view returns (uint256) {
    return hTokens.length;
  }

  // Returns the address of the HToken contract with the given index.
  function getHTokenAddressAtIndex(uint256 index) public view returns (address) {
    return hTokens[index].address;
  }

  // Returns the name of the HToken contract with the given index.
  function getHTokenNameAtIndex(uint256 index) public view returns (string memory) {
    return hTokens[index].name();
  }

  // Returns the symbol of the HToken contract with the given index.
  function getHTokenSymbolAtIndex(uint256 index) public view returns (string memory) {
    return hTokens[index].symbol();
  }
  event HTokenRegistered(address hTokenAddress, string name, string symbol);
event HTokenUnregistered(address hTokenAddress);
event Exchange(address fromTokenAddress, uint256 fromAmount, address toTokenAddress, uint256 toAmount);

}
