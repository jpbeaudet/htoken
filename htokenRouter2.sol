// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./HToken.sol";

contract HTokenRouter {
    // Swaps one HToken for another
    function swapExactHTKForHTK(
        address fromHTK,
        uint256 fromAmount,
        address toHTK
    ) public {
        // Get the instances of the HToken contracts
        HToken fromToken = HToken(fromHTK);
        HToken toToken = HToken(toHTK);

        // Ensure that the caller has sufficient balance of the from HToken
        require(
            fromToken.balanceOf(msg.sender) >= fromAmount,
            "Insufficient from HToken balance"
        );

        // Calculate the paxGold equivalent value of the fromAmount
        uint256 paxGoldValue = fromToken.value().mul(fromAmount);

        // Transfer the fromHTK from the caller to the router, and approve the router to spend the fromAmount
        fromToken.transferFrom(msg.sender, address(this), fromAmount);
        fromToken.approve(address(fromToken), fromAmount);

        // Burn the fromToken and retrieve the paxGoldValue
        fromToken.burn(fromAmount);

        // Transfer the paxGold to the toHTK contract and approve the router to spend the necessary amount of paxGold on behalf of the toHTK contract
        IERC20 paxGold = fromToken.paxGold();
        paxGold.transfer(toHTK, paxGoldValue);
        paxGold.approve(address(toToken), paxGoldValue);

        // Mint the new toTokens using the paxGoldValue and send them to the caller
        toToken.mint(paxGoldValue);
        uint256 toAmount = paxGoldValue.div(toToken.value());
        toToken.transfer(msg.sender, toAmount);

        emit Swap(
            msg.sender,
            fromAmount,
            fromHTK,
            toHTK,
            toAmount
        );
    }

    event Swap(
        address indexed user,
        uint256 amount,
        address indexed fromHTK,
        address indexed toHTK,
        uint256 toAmount
    );
}
