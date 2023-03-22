// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./HToken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract HTokenFactory {
    IERC20 public paxGold;
    uint256 public burnFee;
    uint256 public maxBurnFee;
    uint256 public minDeposit;

    address[] public hTokens;

    event HTokenCreated(address hTokenAddress, string name, string symbol);

    constructor(
        IERC20 _paxGold,
        uint256 _burnFee,
        uint256 _maxBurnFee,
        uint256 _minDeposit
    ) {
        paxGold = _paxGold;
        burnFee = _burnFee;
        maxBurnFee = _maxBurnFee;
        minDeposit = _minDeposit;
    }

    function createHToken(string memory name, string memory symbol) public {
        require(paxGold.balanceOf(msg.sender) >= minDeposit, "Insufficient PaxGold balance");

        HToken hToken = new HToken(paxGold, burnFee, maxBurnFee, name, symbol);
        paxGold.transferFrom(msg.sender, address(hToken), minDeposit);
        hToken.mint(minDeposit);
        hTokens.push(address(hToken));
        emit HTokenCreated(address(hToken), name, symbol);
    }

    function getHTokenCount() public view returns (uint256) {
        return hTokens.length;
    }

    function getHTokenAtIndex(uint256 index) public view returns (address) {
        require(index < hTokens.length, "Index out of bounds");
        return hTokens[index];
    }

    function getHTokenNameAtIndex(uint256 index) public view returns (string memory) {
        address hTokenAddress = getHTokenAtIndex(index);
        HToken hToken = HToken(hTokenAddress);
        return hToken.name();
    }

    function getHTokenSymbolAtIndex(uint256 index) public view returns (string memory) {
        address hTokenAddress = getHTokenAtIndex(index);
        HToken hToken = HToken(hTokenAddress);
        return hToken.symbol();
    }
}
