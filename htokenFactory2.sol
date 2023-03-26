// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.0;

import "./HToken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title HTokenFactory
 * @dev This contract allows users to create and manage HTokens
 * backed by Pax Gold (PAXG) and view details about the HTokens created
 */
contract HTokenFactory {
    IERC20 public paxGold; // The PAXG contract

    mapping(uint256 => address) public hTokenIndexToAddress; // Mapping of HToken index to HToken contract address
    mapping(address => string) public hTokenName; // Mapping of HToken contract address to HToken name
    mapping(address => string) public hTokenSymbol; // Mapping of HToken contract address to HToken symbol
    mapping(string => address) public hTokenNameToAddress; // Mapping of HToken name to HToken contract address
    mapping(string => address) public hTokenSymbolToAddress; // Mapping of HToken symbol to HToken contract address
    uint256 public hTokenCount; // The total number of HTokens created

    event HTokenCreated(address hTokenAddress, string name, string symbol); // Event emitted when a new HToken is created

    /**
     * @dev Constructor for HTokenFactory contract
     * @param _paxGold The address of the PAXG contract
     */
    constructor(
        IERC20 _paxGold
    ) {
        paxGold = _paxGold;
    }

    /**
     * @dev Create a new HToken
     * @param name The name of the HToken
     * @param symbol The symbol of the HToken
     * @param initialDeposit The initial amount of PAXG to deposit into the HToken reserve
     * @param initialSupply The initial supply of HToken to mint
     */
    function createHToken(string memory name, string memory symbol, uint256 initialDeposit, uint256 initialSupply) public {
        require(initialDeposit > 0, "Initial deposit must be greater than zero");
        require(initialSupply > 0, "Initial supply must be greater than zero");
        require(paxGold.balanceOf(msg.sender) >= initialDeposit, "Insufficient PaxGold balance");
        require(hTokenNameToAddress[name] == address(0), "HToken name already exists");
        require(hTokenSymbolToAddress[symbol] == address(0), "HToken symbol already exists");
        require(paxGold.allowance(msg.sender, address(this)) >= initialDeposit, "Factory is not approved to spend PAXG on behalf of user");

        HToken hToken = new HToken(paxGold, initialDeposit, initialSupply, name, symbol, msg.sender);

        uint256 index = hTokenCount;
        hTokenIndexToAddress[index] = address(hToken);
        hTokenName[address(hToken)] = name;
        hTokenSymbol[address(hToken)] = symbol;
        hTokenNameToAddress[name] = address(hToken);
        hTokenSymbolToAddress[symbol] = address(hToken);
        hTokenCount++;

        emit HTokenCreated(address(hToken), name, symbol);
    }

    /**
    * @dev Get all HTokens created
    * @return An array of addresses representing all HTokens created
    */
    function getAllHTokens() public view returns(address[] memory) {
    	address[] memory hTokens = new address[](hTokenCount);
    	for (uint256 i = 0; i < hTokenCount; i++) {
        	hTokens[i] = hTokenIndexToAddress[i];
    	}
    	return hTokens;
    }

    /**

    @dev Get details of an HToken by its index
    @param index The index of the HToken to get details of
    @return A tuple containing the HToken's address, name, symbol, total supply, and current value
    */
    function getHTokenDetailsByIndex(uint256 index) public view returns(address, string memory, string memory, uint256, uint256) {
        require(index < hTokenCount, "Index out of bounds");
        address hTokenAddress = hTokenIndexToAddress[index];
        HToken hToken = HToken(hTokenAddress);
        return (hTokenAddress, hToken.name(), hToken.symbol(), hToken.totalSupply(), hToken.value());
    }
    /**

    @dev Get the total number of HTokens created
    @return The total number of HTokens created
    */
    function getHTokenCount() public view returns(uint256) {
        return hTokenCount;
    }
    /**

    @dev Get the address of an HToken by its index
    @param index The index of the HToken to get the address of
    @return The address of the HToken
    */
    function getHTokenAtIndex(uint256 index) public view returns(address) {
        require(index < hTokenCount, "Index out of bounds");
        return hTokenIndexToAddress[index];
    }
    /**

    @dev Get the name of an HToken by its index
    @param index The index of the HToken to get the name of
    @return The name of the HToken
    */
    function getHTokenNameAtIndex(uint256 index) public view returns(string memory) {
        address hTokenAddress = getHTokenAtIndex(index);
        return hTokenName[hTokenAddress];
    }
    /**

    @dev Get the symbol of an HToken by its index
    @param index The index of the HToken to get the symbol of
    @return The symbol of the HToken
    */
    function getHTokenSymbolAtIndex(uint256 index) public view returns(string memory) {
        address hTokenAddress = getHTokenAtIndex(index);
        return hTokenSymbol[hTokenAddress];
    }
    /**

    @dev Get the address of an HToken by its name
    @param name The name of the HToken to get the address of
    @return The address of the HToken
    */
    function getHTokenByName(string memory name) public view returns(address) {
        return hTokenNameToAddress[name];
    }
    /**

    @dev Get the address of an HToken by its symbol
    @param symbol The symbol of the HToken to get the address of
    @return The address of the HToken
    */
    function getHTokenBySymbol(string memory symbol) public view returns(address) {
        return hTokenSymbolToAddress[symbol];
    }
