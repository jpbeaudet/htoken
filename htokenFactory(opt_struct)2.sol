// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./HToken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title HTokenFactory
 * @dev A factory contract to create and manage HTokens.
 */
contract HTokenFactory {
    // The underlying asset - Pax Gold.
    IERC20 public paxGold;

    // Struct to store HToken data.
    struct HTokenData {
        address hTokenAddress;
        string name;
        string symbol;
        bool exists;
    }

    // Mapping from index to HTokenData.
    mapping(uint256 => HTokenData) public hTokenIndexToData;

    // Mapping from HToken name to index.
    mapping(string => uint256) public hTokenNameToIndex;

    // Mapping from HToken symbol to index.
    mapping(string => uint256) public hTokenSymbolToIndex;

    // Total count of HTokens created by the factory.
    uint256 public hTokenCount;

    // Event to be emitted when an HToken is created.
    event HTokenCreated(address indexed hTokenAddress, string name, string symbol);

    /**
     * @dev Constructor to initialize the HTokenFactory contract.
     * @param _paxGold Address of the Pax Gold (PAXG) token contract.
     */
    constructor(
        IERC20 _paxGold
    ) {
        paxGold = _paxGold;
    }

    /**
     * @dev Creates an HToken with the specified parameters.
     * @param name The name of the new HToken.
     * @param symbol The symbol of the new HToken.
     * @param initialDeposit The initial amount of Pax Gold to be deposited into the HToken contract.
     * @param initialSupply The initial supply of the new HToken.
     */
    function createHToken(
        string memory name,
        string memory symbol,
        uint256 initialDeposit,
        uint256 initialSupply
    ) public {
        require(initialDeposit > 0, "Initial deposit must be greater than zero");
        require(initialSupply > 0, "Initial supply must be greater than zero");
        require(paxGold.balanceOf(msg.sender) >= initialDeposit, "Insufficient PaxGold balance");
        require(hTokenIndexToData[hTokenNameToIndex[name]].exists == false, "HToken name already exists");
        require(hTokenIndexToData[hTokenSymbolToIndex[symbol]].exists == false, "HToken symbol already exists");
        require(paxGold.allowance(msg.sender, address(this)) >= initialDeposit, "Factory is not approved to spend PAXG on behalf of user");

        HToken hToken = new HToken(paxGold, initialDeposit, initialSupply, name, symbol, msg.sender);
        require(paxGold.transferFrom(msg.sender, address(htoken), initialDeposit), "Token transfer failed");
        uint256 index = hTokenCount;
        hTokenIndexToData[index] = HTokenData({
            hTokenAddress: address(hToken),
            name: name,
            symbol: symbol,
            exists: true
        });
        hTokenNameToIndex[name] = index;
        hTokenSymbolToIndex[symbol] = index;
        hTokenCount++;

        emit HTokenCreated(address(hToken), name, symbol);
    }
    /**
     * @dev Retrieves HToken details by its index.
     * @param index The index of the HToken.
     * @return The address, name, and symbol of the HToken.
     */
    function getHTokenDetailsByIndex(uint256 index) public view returns (address, string memory, string memory) {
        require(index < hTokenCount, "Index out of bounds");
        HTokenData storage hTokenData = hTokenIndexToData[index];
        return (hTokenData.hTokenAddress, hTokenData.name, hTokenData.symbol);
    }

    /**
     * @dev Retrieves the HToken address by its name.
     * @param name The name of the HToken.
     * @return The address of the HToken with the given name.
     */
    function getHTokenByName(string memory name) public view returns (address) {
        uint256 index = hTokenNameToIndex[name];
        require(hTokenIndexToData[index].exists, "HToken name does not exist");
        return hTokenIndexToData[index].hTokenAddress;
    }

    /**
     * @dev Retrieves the HToken address by its symbol.
     * @param symbol The symbol of the HToken.
     * @return The address of the HToken with the given symbol.
     */
    function getHTokenBySymbol(string memory symbol) public view returns (address) {
        uint256 index = hTokenSymbolToIndex[symbol];
        require(hTokenIndexToData[index].exists, "HToken symbol does not exist");
        return hTokenIndexToData[index].hTokenAddress;
    }
}
