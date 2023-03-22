HToken Protocol
===============

The HToken Protocol is a decentralized exchange protocol built on the Ethereum blockchain. It allows users to exchange one HToken for another.

Overview
--------

The HToken Protocol is composed of three smart contracts:

1.  `HToken.sol` - The HToken contract represents a specific HToken on the HToken Protocol. It inherits from the `ERC20` contract and provides additional functionality specific to the HToken Protocol.
2.  `HTokenFactory.sol` - The HTokenFactory contract is responsible for creating new HToken contracts. It stores information about all created HToken contracts and provides methods for querying them.
3.  `HTokenRouter.sol` - The HTokenRouter contract provides a way to exchange one HToken for another on the HToken Protocol.

HToken.sol
----------

The HToken contract is a standard ERC20 token with the following additional functionality:

1.  `mint` - Allows users to mint new HToken by depositing PAX Gold. The value of the new HToken is determined by the current value of PAX Gold.
2.  `burn` - Allows users to burn HToken and receive PAX Gold in return. The value of the burned HToken is determined by the current value of PAX Gold.
3.  `transfer` - Overrides the `transfer` function from the `ERC20` contract to take a percentage of the transferred amount as a burn fee.

HTokenFactory.sol
-----------------

The HTokenFactory contract is responsible for creating new HToken contracts. It stores information about all created HToken contracts and provides methods for querying them.

HTokenRouter.sol
----------------

The HTokenRouter contract provides a way to exchange one HToken for another on the HToken Protocol. It uses the `HToken` contract to determine the value of the HToken being exchanged.

Usage
-----

To use the HToken Protocol, you can follow these steps:

1.  Deploy the `HTokenFactory` contract.
2.  Call the `createHToken` function on the `HTokenFactory` contract to create a new HToken.
3.  Use the `HTokenRouter` contract to exchange one HToken for another.

License
-------

The HToken Protocol is licensed under the MIT License.
