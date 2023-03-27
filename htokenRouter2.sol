// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./HToken.sol";
import "./HTokenFactory.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title HTokenRouter
 * @dev A router contract for interacting with HToken instances and
 * performing token swaps.
 */
contract HTokenRouter is ReentrancyGuard {
    HTokenFactory public factory;

    /**
     * @dev Constructor to initialize the HTokenRouter with the HTokenFactory address.
     * @param _factory The address of the HTokenFactory contract.
     */
    constructor(HTokenFactory _factory) {
        factory = _factory;
    }

    /**
     * @dev Function to check if an HToken contract is valid.
     * @param htk The address of the HToken contract.
     * @return A boolean indicating if the HToken contract is valid.
     */
    function isValidHTK(address htk) public view returns (bool) {
        (address hTokenAddress, , , bool exists) = factory.hTokenIndexToData(factory.hTokenAddressToIndex[htk]);
        return exists && hTokenAddress == htk;
    }

    /**
     * @dev Function to get the HToken balances of a user.
     * @param user The address of the user.
     * @return An array of the user's HToken balances.
     */
    function getUserBalances(address user) public view returns (uint256[] memory) {
        uint256 hTokenCount = factory.getHTokenCount();
        uint256[] memory hTokenBalances = new uint256[](hTokenCount);
        for (uint256 i = 0; i < hTokenCount; i++) {
            address hTokenAddress = factory.getHTokenAtIndex(i);
            HToken hToken = HToken(hTokenAddress);
            hTokenBalances[i] = hToken.balanceOf(user);
        }
        return (hTokenBalances);
    }

    /**
     * @dev Function to swap one HToken for another.
     * @param fromHTK The address of the HToken to swap from.
     * @param fromAmount The amount of fromHTK to swap.
     * @param toHTK The address of the HToken to swap to.
     */
    function swapExactHTKForHTK(
        address fromHTK,
        uint256 fromAmount,
        address toHTK
    ) public nonReentrant {
        // Ensure that the fromHTK and toHTK are valid HToken contracts
        require(isValidHTK(fromHTK), "fromHTK is not a valid HToken contract");
        require(isValidHTK(toHTK), "toHTK is not a valid HToken contract");

        // Get the instances of the HToken contracts
        HToken fromToken = HToken(fromHTK);
        HToken toToken = HToken(toHTK);

        // Ensure that the caller has sufficient balance of the from HToken
        require(
            fromToken.balanceOf(msg.sender) >= fromAmount,
            "Insufficient from HToken balance"
        );

        // Calculate the paxGold equivalent value of the fromAmount
        uint256 paxGoldValue = fromToken._updateValue().mul(fromAmount);

        // Transfer the fromHTK from the caller to the router, and approve the router to spend the fromAmount
        fromToken.transferFrom(msg.sender, address(this), fromAmount);
        fromToken.approve(address(fromToken), fromAmount);

         // Burn the fromToken and retrieve the paxGoldValue
        fromToken.burn(fromAmount); // this will return paxg to the factory

        // Transfer the paxGold to the toHTK contract and approve the router to spend the necessary amount of paxGold on behalf of the toHTK contract
        IERC20 paxGold = fromToken.paxGold();
        // paxGold.transfer(toHTK, paxGoldValue); // the transfer is already handled by the htoken contract
        paxGold.approve(address(toToken), paxGoldValue);

        // Mint the new toTokens using the paxGoldValue and send them to the caller
        toToken.mint(paxGoldValue); // this will consume paxg fromt he factory and return new htokens
        uint256 toAmount = paxGoldValue.div(toToken._updateValue());
        toToken.transfer(msg.sender, toAmount); // send the htoken that were recieved in the mint phase

        // Emit the Swap event
        emit Swap(
            msg.sender,
            fromAmount,
            fromHTK,
            toHTK,
            toAmount
        );
    }

    /**
     * @dev Event emitted when a token swap occurs.
     * @param user The address of the user performing the swap.
     * @param amount The amount of the HToken being swapped from.
     * @param fromHTK The address of the HToken being swapped from.
     * @param toHTK The address of the HToken being swapped to.
     * @param toAmount The amount of the HToken being swapped to.
     */
    event Swap(
        address indexed user,
        uint256 amount,
        address indexed fromHTK,
        address indexed toHTK,
        uint256 toAmount
    );
}
