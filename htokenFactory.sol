// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./HToken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract HTokenFactory {
    IERC20 public paxGold;

    mapping(uint256 => address) public hTokenIndexToAddress;
    mapping(address => string) public hTokenName;
    mapping(address => string) public hTokenSymbol;
    mapping(string => address) public hTokenNameToAddress;
    mapping(string => address) public hTokenSymbolToAddress;
    uint256 public hTokenCount;

    event HTokenCreated(address hTokenAddress, string name, string symbol);

    constructor(
        IERC20 _paxGold,
    ) {
        paxGold = _paxGold;
    }

    function createHToken(string memory name, string memory symbol, uint256 initialDeposit, uint256 initialSupply) public {
        require(initialDeposit > 0, "Initial deposit must be greater than zero");
        require(initialSupply > 0, "Initial supply must be greater than zero");
        require(paxGold.balanceOf(msg.sender) >= initialDeposit, "Insufficient PaxGold balance");
        require(hTokenNameToAddress[name] == address(0), "HToken name already exists");
        require(hTokenSymbolToAddress[symbol] == address(0), "HToken symbol already exists");

        HToken hToken = new HToken(paxGold, initialDeposit, initialSupply, name, symbol);
        require(paxGold.transferFrom(msg.sender, address(hToken), initialDeposit), "Token transfer failed");

        uint256 index = hTokenCount;
        hTokenIndexToAddress[index] = address(hToken);
        hTokenName[address(hToken)] = name;
        hTokenSymbol[address(hToken)] = symbol;
        hTokenNameToAddress[name] = address(hToken);
        hTokenSymbolToAddress[symbol] = address(hToken);
        hTokenCount++;

        emit HTokenCreated(address(hToken), name, symbol);
    }
    
    function getAllHTokens() public view returns (address[] memory) {
        address[] memory hTokens = new address[](hTokenCount);
         for (uint256 i = 0; i < hTokenCount; i++) {
             hTokens[i] = hTokenIndexToAddress[i];
         }
        return hTokens;
    }
    
    function getHTokenDetailsByIndex(uint256 index) public view returns (address, string memory, string memory, uint256, uint256) {
        require(index < hTokenCount, "Index out of bounds");
        address hTokenAddress = hTokenIndexToAddress[index];
        HToken hToken = HToken(hTokenAddress);
     return (hTokenAddress, hToken.name(), hToken.symbol(), hToken.totalSupply(), hToken.value());
    }

    function getHTokenCount() public view returns (uint256) {
        return hTokenCount;
    }

    function getHTokenAtIndex(uint256 index) public view returns (address) {
        require(index < hTokenCount, "Index out of bounds");
        return hTokenIndexToAddress[index];
    }

    function getHTokenNameAtIndex(uint256 index) public view returns (string memory) {
        address hTokenAddress = getHTokenAtIndex(index);
        return hTokenName[hTokenAddress];
    }

    function getHTokenSymbolAtIndex(uint256 index) public view returns (string memory) {
        address hTokenAddress = getHTokenAtIndex(index);
        return hTokenSymbol[hTokenAddress];
    }

    function getHTokenByName(string memory name) public view returns (address) {
        return hTokenNameToAddress[name];
    }

    function getHTokenBySymbol(string memory symbol) public view returns (address) {
        return hTokenSymbolToAddress[symbol];
    }
}
