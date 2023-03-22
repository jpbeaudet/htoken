// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./HToken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract HTokenFactory {
    IERC20 public paxGold;
    uint256 public burnFee;
    uint256 public maxBurnFee;
    uint256 public minDeposit;

    mapping(uint256 => address) public hTokenIndexToAddress;
    mapping(address => string) public hTokenName;
    mapping(address => string) public hTokenSymbol;
    mapping(string => address) public hTokenNameToAddress;
    mapping(string => address) public hTokenSymbolToAddress;
    uint256 public hTokenCount;

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
    require(hTokenNameToAddress[name] == address(0), "HToken name already exists"); // Ensure that the name is not already in use
    require(hTokenSymbolToAddress[symbol] == address(0), "HToken symbol already exists"); // Ensure that the symbol is not already in use

    HToken hToken = new HToken(paxGold, burnFee, maxBurnFee, name, symbol);
    require(address(hToken) != address(0), "Invalid HToken contract address"); // Ensure that the HToken contract was successfully created
    require(hToken.totalSupply() > 0, "Invalid HToken total supply"); // Ensure that the HToken contract has a non-zero total supply
    require(hToken.name() == name && hToken.symbol() == symbol, "HToken name and symbol do not match parameters");

    paxGold.transferFrom(msg.sender, address(hToken), minDeposit);
    hToken.mint(minDeposit);

    uint256 index = hTokenCount;
    require(hTokenIndexToAddress[index] == address(0), "Invalid HToken index"); // Ensure that the HToken index is not already in use
    hTokenIndexToAddress[index] = address(hToken);
    hTokenName[address(hToken)] = name;
    hTokenSymbol[address(hToken)] = symbol;
    hTokenNameToAddress[name] = address(hToken);
    hTokenSymbolToAddress[symbol] = address(hToken);
    hTokenCount++;

    emit HTokenCreated(address(hToken), name, symbol);
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
