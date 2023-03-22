// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./HToken.sol";
import "./HTokenFactory.sol";

contract HTokenRouter {
    HTokenFactory public factory;

    // Exchanges one HToken for another.
    function swapExactHTKForHTK(address fromHTK, uint256 fromAmount, address toHTK) public {
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
