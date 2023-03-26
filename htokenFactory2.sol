// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./HToken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title HTokenFactory
 * @dev A factory contract for creating HToken instances.
 */
contract HTokenFactory {
    IERC20 public paxGold;

    // Struct to store HToken data
    struct HTokenData {
        address hTokenAddress;
        string name;
        string symbol;
        bool exists;
    }

    // Mappings to store HToken data by index, name, symbol, and address
    mapping(uint256 => HTokenData) public hTokenIndexToData;
    mapping(string => uint256) public hTokenNameToIndex;
    mapping(string => uint256) public hTokenSymbolToIndex;
    mapping(address => uint256) public hTokenAddressToIndex;
    uint256 public hTokenCount;

    event HTokenCreated(address indexed hTokenAddress, string name, string symbol);

    /**
     * @dev Constructor to initialize the HTokenFactory with the address of the paxGold ERC20 token.
     * @param _paxGold The address of the paxGold ERC20 token.
     */
    constructor(
        IERC20 _paxGold
    ) {
        paxGold = _paxGold;
    }

    /**
     * @dev Function to create a new HToken instance.
     * @param name The name of the new HToken.
     * @param symbol The symbol of the new HToken.
     * @param initialDeposit The initial amount of paxGold to be deposited in the new HToken.
     * @param initialSupply The initial supply of the new HToken.
     */
    function createHToken(string memory name, string memory symbol, uint256 initialDeposit, uint256 initialSupply) public {
        // Validate input parameters
        require(initialDeposit > 0, "Initial deposit must be greater than zero");
        require(initialSupply > 0, "Initial supply must be greater than zero");
        require(paxGold.balanceOf(msg.sender) >= initialDeposit, "Insufficient PaxGold balance");
        require(hTokenIndexToData[hTokenNameToIndex[name]].exists == false, "HToken name already exists");
        require(hTokenIndexToData[hTokenSymbolToIndex[symbol]].exists == false, "HToken symbol already exists");
        require(paxGold.allowance(msg.sender, address(this)) >= initialDeposit, "Factory is not approved to spend PAXG on behalf of user");

        // Create a new HToken instance and transfer the initial deposit of paxGold
        HToken hToken = new HToken(paxGold, initialDeposit, initialSupply, name, symbol, msg.sender);
        require(paxGold.transferFrom(msg.sender, address(hToken), initialDeposit), "Token transfer failed");

        // Store HToken data in the mappings
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

  /**
 * @dev Function to get the total number of HToken instances.
 * @return The total count of HToken instances.
 */
function getHTokenCount() public view returns (uint256) {
    return hTokenCount;
}

/**
 * @dev Function to get the HToken details by index.
 * @param index The index of the HToken.
 * @return The HToken address, name, and symbol.
 */
function getHTokenDetailsByIndex(uint256 index) public view returns (address, string memory, string memory) {
    require(index < hTokenCount, "Index out of bounds");
    HTokenData storage hTokenData = hTokenIndexToData[index];
    return (hTokenData.hTokenAddress, hTokenData.name, hTokenData.symbol);
}

/**
 * @dev Function to get the HToken index by address.
 * @param target The address of the HToken.
 * @return The index of the HToken.
 */
function getHTokenIndexByAddress(address target) public view returns (uint256) {
    uint256 index = hTokenAddressToIndex[target];
    require(hTokenIndexToData[index].exists, "HToken index does not exist");
    return index;
}

/**
 * @dev Function to get the HToken address by name.
 * @param name The name of the HToken.
 * @return The address of the HToken.
 */
function getHTokenByName(string memory name) public view returns (address) {
    uint256 index = hTokenNameToIndex[name];
    require(hTokenIndexToData[index].exists, "HToken name does not exist");
    return hTokenIndexToData[index].hTokenAddress;
}

/**
 * @dev Function to get the HToken address by symbol.
 * @param symbol The symbol of the HToken.
 * @return The address of the HToken.
 */
function getHTokenBySymbol(string memory symbol) public view returns (address) {
    uint256 index = hTokenSymbolToIndex[symbol];
    require(hTokenIndexToData[index].exists, "HToken symbol does not exist");
    return hTokenIndexToData[index].hTokenAddress;
}
}
