// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./HToken.sol";
import "./HTokenFactory.sol";

contract HTokenRouter {
    HTokenFactory public factory;

    // Registers an HToken contract for exchange.
    function registerHToken(address hTokenAddress) public {
        // Ensure that the caller is the owner of the HToken contract.
        require(factory.hTokenName(hTokenAddress) != "", "HToken does not exist in factory");
        require(factory.hTokenSymbol(hTokenAddress) != "", "HToken does not exist in factory");

        // Create an instance of the HToken contract.
        HToken hToken = HToken(hTokenAddress);

        // Ensure that the caller is the owner of the HToken contract.
        require(hToken.owner() == msg.sender, "Only the owner of the HToken contract can register it for exchange");

        // Register the HToken contract for exchange.
        factory.registerHToken(hToken);
    }

    // Unregisters an HToken contract from the exchange.
    function unregisterHToken(address hTokenAddress) public {
        // Ensure that the caller is the owner of the HToken contract.
        require(factory.hTokenName(hTokenAddress) != "", "HToken does not exist in factory");
        require(factory.hTokenSymbol(hTokenAddress) != "", "HToken does not exist in factory");

        // Create an instance of the HToken contract.
        HToken hToken = HToken(hTokenAddress);

        // Ensure that the caller is the owner of the HToken contract.
        require(hToken.owner() == msg.sender, "Only the owner of the HToken contract can unregister it from the exchange");

        // Unregister the HToken contract from the exchange.
        factory.unregisterHToken(hTokenAddress);
    }

    // Exchanges one HToken for another.
    function swapExactHTKForHTK(address fromHTK, uint256 fromAmount, address toHTK) public {
        // Ensure that both HToken contracts are registered for exchange.
        require(factory.hTokenName(fromHTK) != "", "From HToken is not registered for exchange");
        require(factory.hTokenSymbol(fromHTK) != "", "From HToken is not registered for exchange");
        require(factory.hTokenName(toHTK) != "", "To HToken is not registered for exchange");
        require(factory.hTokenSymbol(toHTK) != "", "To HToken is not registered for exchange");

        // Get the instances of the HToken contracts.
        HToken fromToken = HToken(fromHTK);
        HToken toToken = HToken(toHTK);

        // Ensure that the caller has sufficient balance of the from HToken.
        require(fromToken.balanceOf(msg.sender) >= fromAmount, "Insufficient from HToken balance");

        // Calculate the number of to HTokens to be received.
        uint256 toAmount = fromToken.updateValue(fromAmount, toHTK);

        // Transfer the from HTokens from the caller to the exchange contract.
        fromToken.transferFrom(msg.sender, address(this), fromAmount);

        // Transfer the to HTokens from the exchange contract to the caller.
        toToken.transfer(msg.sender, toAmount);
        emit Swap(msg.sender, fromAmount, fromHTK, toHTK, toAmount);
    }

    // Sets the address of the HTokenFactory contract.
    function setHTokenFactory(address factoryAddress) public {
        factory = HTokenFactory(factoryAddress);
    }

    event Swap(address indexed user, uint256 amount, address indexed fromHTK, address indexed toHTK, uint256 toAmount);
}
