// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8 .0;

import "./HToken.sol";
import "./HTokenFactory.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**

@title HTokenRouter

@dev Router contract for swapping HTokens
*/
contract HTokenRouter is ReentrancyGuard {

    HTokenFactory public factory;

    /**

    @dev Constructor for HTokenRouter contract
    @param _factory The HTokenFactory contract address
    */
    constructor(HTokenFactory _factory) {
        factory = _factory;
    }
    /**

    @dev Check if an HToken contract is valid
    @param htk The address of the HToken contract
    @return A boolean indicating if the HToken contract is valid or not
    */
    function isValidHTK(address htk) public view returns(bool) {
        return factory.getHTokenByName(factory.hTokenName(htk)) == htk;
    }
    /**

    @dev Get the balances of a user for all HTokens
    @param user The address of the user
    @return An array of uint256 values containing the user's balance for each HToken
    */
    function getUserBalances(address user) public view returns(uint256[] memory) {
        uint256 hTokenCount = factory.getHTokenCount();
        uint256[] memory hTokenBalances = new uint256;
        for (uint256 i = 0; i < hTokenCount; i++) {
            address hTokenAddress = factory.getHTokenAtIndex(i);
            HToken hToken = HToken(hTokenAddress);
            hTokenBalances[i] = hToken.balanceOf(user);
        }
        return (hTokenBalances);
    }
    /**

    @dev Swap one HToken for another

    @param fromHTK The address of the HToken being swapped

    @param fromAmount The amount of fromHTK being swapped

    @param toHTK The address of the HToken to receive in exchange
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
        uint256 paxGoldValue = fromToken.value().mul(fromAmount);

        // Transfer the fromHTK from the caller to the router, and approve the router to spend the fromAmount
        fromToken.transferFrom(msg.sender, address(this), fromAmount);
        fromToken.approve(address(fromToken), fromAmount);

        // Burn the fromToken and retrieve the paxGoldValue
        fromToken.burn(fromAmount);

        // Transfer the paxGold to the toHTK contract and approve the router to spend the necessary amount of paxGold on behalf of the toHTK contract
        IERC20 paxGold = fromToken.paxGold;
        paxGold.transfer(toHTK, paxGoldValue);
        paxGold.approve(address(toToken), paxGoldValue);

        // Mint the new toTokens using the paxGoldValue and send them to the caller
        toToken.mint(paxGoldValue);
        uint256 toAmount = paxGoldValue.div(toToken.value());
        toToken.transfer(msg.sender, toAmount);

        // Emit swap event
        emit Swap(
            msg.sender,
            fromAmount,
            fromHTK,
            toHTK,
            toAmount
        );
    }

    /**
     * @dev Event emitted when an HToken swap is made
     * @param user The address of the user making the swap
     * @param amount The amount of the fromHTK being swapped
     * @param fromHTK The address of the HToken being swapped
     * @param toHTK The address of the HToken received in exchange
     * @param toAmount The amount of the toHTK received in exchange
     */
    event Swap(
        address indexed user,
        uint256 amount,
        address indexed fromHTK,
        address indexed toHTK,
        uint256 toAmount
    );
