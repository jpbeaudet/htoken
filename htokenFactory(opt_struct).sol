// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./HToken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract HTokenFactory {
    IERC20 public paxGold;

    struct HTokenData {
        address hTokenAddress;
        string name;
        string symbol;
        bool exists;
    }

    mapping(uint256 => HTokenData) public hTokenIndexToData;
    mapping(string => uint256) public hTokenNameToIndex;
    mapping(string => uint256) public hTokenSymbolToIndex;
    mapping(address => uint256) public hTokenAddressToIndex;
    uint256 public hTokenCount;

    event HTokenCreated(address indexed hTokenAddress, string name, string symbol);

    constructor(
        IERC20 _paxGold
    ) {
        paxGold = _paxGold;
    }

    function createHToken(string memory name, string memory symbol, uint256 initialDeposit, uint256 initialSupply) public {
        require(initialDeposit > 0, "Initial deposit must be greater than zero");
        require(initialSupply > 0, "Initial supply must be greater than zero");
        require(paxGold.balanceOf(msg.sender) >= initialDeposit, "Insufficient PaxGold balance");
        require(hTokenIndexToData[hTokenNameToIndex[name]].exists == false, "HToken name already exists");
        require(hTokenIndexToData[hTokenSymbolToIndex[symbol]].exists == false, "HToken symbol already exists");
        require(paxGold.allowance(msg.sender, address(this)) >= initialDeposit, "Factory is not approved to spend PAXG on behalf of user");

        HToken hToken = new HToken(paxGold, initialDeposit, initialSupply, name, symbol, msg.sender);
        require(paxGold.transferFrom(msg.sender, address(hToken), initialDeposit), "Token transfer failed");
        uint256 index = hTokenCount;
        hTokenIndexToData[index] = HTokenData({
            hTokenAddress: address(hToken),
            name: name,
            symbol: symbol,
            exists: true
        });
        hTokenNameToIndex[name] = index;
        hTokenSymbolToIndex[symbol] = index;
        hTokenAddressToIndex[address(hToken)] = index;
        hTokenCount++;

        emit HTokenCreated(address(hToken), name, symbol);
    }
    
    function getHTokenCount() public view returns (uint256) {
        return hTokenCount;
    }

    function getHTokenDetailsByIndex(uint256 index) public view returns (address, string memory, string memory) {
        require(index < hTokenCount, "Index out of bounds");
        HTokenData storage hTokenData = hTokenIndexToData[index];
        return (hTokenData.hTokenAddress, hTokenData.name, hTokenData.symbol);
    }
    
    function getHTokenIndexByAddress(address target) public view returns (uint256) {
        uint256 index = hTokenAddressToIndex[target];
        require(hTokenIndexToData[index].exists, "HToken index does not exist");
        return index;
    }

    function getHTokenByName(string memory name) public view returns (address) {
        uint256 index = hTokenNameToIndex[name];
        require(hTokenIndexToData[index].exists, "HToken name does not exist");
        return hTokenIndexToData[index].hTokenAddress;
    }

    function getHTokenBySymbol(string memory symbol) public view returns (address) {
        uint256 index = hTokenSymbolToIndex[symbol];
        require(hTokenIndexToData[index].exists, "HToken symbol does not exist");
        return hTokenIndexToData[index].hTokenAddress;
    }
}
