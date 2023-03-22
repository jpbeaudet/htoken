pragma solidity ^0.8.0;

import "./HToken.sol";

contract HTokenRouter {
    // The HToken contracts that are available for exchange.
    mapping(address => HToken) public hTokens;

    // Registers an HToken contract for exchange.
    function registerHToken(HToken hToken) public {
        // Ensure that the caller is the owner of the HToken contract.
        require(hToken.owner() == msg.sender, "Only the owner of the HToken contract can register it for exchange");

        hTokens[hToken.address()] = hToken;
        emit HTokenRegistered(hToken.address(), hToken.name(), hToken.symbol());
    }

    // Unregisters an HToken contract from the exchange.
    function unregisterHToken(address hTokenAddress) public {
        // Ensure that the caller is the owner of the HToken contract.
        require(hTokens[hTokenAddress].owner() == msg.sender, "Only the owner of the HToken contract can unregister it from the exchange");

        delete hTokens[hTokenAddress];

        emit HTokenUnregistered(hTokenAddress);
    }

    // Exchanges one HToken for another.
    function swapExactHTKForHTK(address fromHTK, uint256 fromAmount, address toHTK) public {
        // Ensure that both HToken contracts are registered for exchange.
        require(hTokens[fromHTK] != HToken(address(0)), "From HToken contract is not registered for exchange");
        require(hTokens[toHTK] != HToken(address(0)), "To HToken contract is not registered for exchange");

        // Ensure that the caller has sufficient balance of the from HToken.
        require(hTokens[fromHTK].balanceOf(msg.sender) >= fromAmount, "Insufficient from HToken balance");

        // Calculate the number of to HTokens to be received.
        uint256 toAmount = hTokens[fromHTK].updateValue(fromAmount, toHTK);

        // Transfer the from HTokens from the caller to the exchange contract.
        hTokens[fromHTK].transferFrom(msg.sender, address(this), fromAmount);

        // Transfer the to HTokens from the exchange contract to the caller.
        hTokens[toHTK].transfer(msg.sender, toAmount);
        emit Swap(msg.sender, fromAmount, fromHTK, toHTK, toAmount);
    }

    // Returns the number of HToken contracts that are registered for exchange.
    function getHTokenCount() public view returns (uint256) {
        return hTokens.length;
    }

    // Returns the address of the HToken contract with the given index.
    function getHTokenAddressAtIndex(uint256 index) public view returns (address) {
        return hTokens[index].address();
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
    event Swap(address indexed user, uint256 amount, address indexed fromHTK, address indexed toHTK, uint256 toAmount);
}
